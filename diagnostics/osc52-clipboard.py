#!/usr/bin/env python3
"""OSC 52 clipboard diagnostic for SSH/mosh + tmux setups."""

import base64
from config import ssh, ssh_grep, check

print("OSC 52 Clipboard Diagnostic\n")

# Test 1: Direct OSC 52
b64 = base64.b64encode(b"TEST").decode()
out, _ = ssh(f"printf '\\033]52;c;{b64}\\007'", text=False)
check("Direct OSC 52", b'\x1b]52' in out or b']52;c;' in out)

# Test 2: osc52-copy script exists
out, _ = ssh("test -x ~/.local/bin/osc52-copy && echo OK")
check("osc52-copy script", "OK" in out)

# Test 3: tmux config
out, _ = ssh_grep("copy-pipe.*osc52", "~/.tmux.conf")
check("tmux y binding", "osc52-copy" in out)

# Test 4: set-clipboard off (we handle it ourselves)
_, ok = ssh_grep("set-clipboard off", "~/.tmux.conf")
check("set-clipboard off", ok)
