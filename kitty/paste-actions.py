# Wired in kitty.conf via `paste_actions filter,...`. Filename is hardcoded
# by kitty (`<config_dir>/paste-actions.py`). API: https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.paste_actions
def filter_paste(text: str) -> str:
    return text.rstrip('\r\n')
