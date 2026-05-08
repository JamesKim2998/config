#!/usr/bin/env python3
"""
Claude Code busy indicator for kitty tabs.

Manually-renamed tabs (`title_overridden: True`) bypass `tab_title_template`,
so we can't render the hourglass via the template. Instead, we mutate the tab
title in-place: append " " on UserPromptSubmit, strip on Stop. Tabs whose
title is template-driven are left untouched (any append would pin them).

Wired up via .claude/settings.json hooks. See [[kitty.conf]] for the template.
Kitty remote control: https://sw.kovidgoyal.net/kitty/remote-control/
"""
import json
import os
import subprocess
import sys

ICON = ""  # nf-fa-hourglass_half
SUFFIX = " " + ICON


def find_my_tab(data, win_id):
    for o in data:
        for t in o.get("tabs", []):
            if any(w.get("id") == win_id for w in t.get("windows", [])):
                return t
    return None


def main(action):
    sock = os.environ.get("KITTY_LISTEN_ON", "")
    my = int(os.environ.get("KITTY_WINDOW_ID", "0"))
    if not sock or not my:
        return

    out = subprocess.run(
        ["kitty", "@", "--to=" + sock, "ls"],
        capture_output=True, text=True, check=True,
    )
    tab = find_my_tab(json.loads(out.stdout), my)
    if not tab or not tab.get("title_overridden"):
        return

    cur = tab.get("title", "")
    if action == "set" and not cur.endswith(SUFFIX):
        new = cur + SUFFIX
    elif action == "clear" and cur.endswith(SUFFIX):
        new = cur[: -len(SUFFIX)]
    else:
        return

    subprocess.run(
        ["kitty", "@", "--to=" + sock, "set-tab-title",
         "--match=id:" + str(tab["id"]), "--", new]
    )


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "set")
