"""Equalize splits layout — used as both a watcher (on_close) and a kitten (ctrl+shift+e)."""
from kittens.tui.handler import result_handler


def _count_on_axis(node, horizontal):
    if node is None:
        return 0
    if isinstance(node, int):
        return 1
    if node.horizontal == horizontal:
        return _count_on_axis(node.one, horizontal) + _count_on_axis(node.two, horizontal)
    return max(_count_on_axis(node.one, horizontal), _count_on_axis(node.two, horizontal))


def _equalize(pair):
    if pair is None or isinstance(pair, int):
        return
    one_count = _count_on_axis(pair.one, pair.horizontal)
    two_count = _count_on_axis(pair.two, pair.horizontal)
    total = one_count + two_count
    if total > 0:
        pair.bias = one_count / total
    _equalize(pair.one)
    _equalize(pair.two)


def _equalize_tab(tab, relayout=True):
    if tab is None:
        return
    layout = tab.current_layout
    if hasattr(layout, 'pairs_root'):
        _equalize(layout.pairs_root)
        if relayout:
            tab.relayout()


# Watcher: set biases only — kitty's own post-removal relayout applies them
def on_close(boss, window, data):
    _equalize_tab(boss.active_tab, relayout=False)


# Kitten: manual equalize via keybinding
def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    _equalize_tab(boss.active_tab)
