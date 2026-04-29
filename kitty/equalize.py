"""Equalize splits layout — used as both a watcher (on_close) and a kitten (ctrl+shift+e)."""
from kittens.tui.handler import result_handler


def _count_on_axis(node, horizontal, skip_id=None):
    if node is None:
        return 0
    if isinstance(node, int):
        return 0 if node == skip_id else 1
    if node.horizontal == horizontal:
        return _count_on_axis(node.one, horizontal, skip_id) + _count_on_axis(node.two, horizontal, skip_id)
    return max(_count_on_axis(node.one, horizontal, skip_id), _count_on_axis(node.two, horizontal, skip_id))


def _equalize(pair, skip_id=None):
    if pair is None or isinstance(pair, int):
        return
    one_count = _count_on_axis(pair.one, pair.horizontal, skip_id)
    two_count = _count_on_axis(pair.two, pair.horizontal, skip_id)
    total = one_count + two_count
    if total > 0:
        pair.bias = one_count / total
    _equalize(pair.one, skip_id)
    _equalize(pair.two, skip_id)


def _equalize_tab(tab, relayout=True, skip_id=None):
    if tab is None:
        return
    layout = tab.current_layout
    if hasattr(layout, 'pairs_root'):
        _equalize(layout.pairs_root, skip_id)
        if relayout:
            tab.relayout()


# Watcher: on_close fires before the window is removed from the layout tree,
# so we must skip its id when counting — otherwise biases reflect the pre-removal
# tree shape and panes look squashed after kitty's post-removal relayout.
def on_close(boss, window, data):
    _equalize_tab(boss.active_tab, relayout=False, skip_id=window.id)


# Kitten: manual equalize via keybinding
def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    _equalize_tab(boss.active_tab)
