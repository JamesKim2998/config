#!/usr/bin/env python3
"""OSC 52 clipboard diagnostic for SSH/mosh + tmux setups."""

import subprocess
import base64
import os

HOST = os.environ.get("SSH_HOST", "jameskim@192.168.219.122")
KEY = os.path.expanduser(os.environ.get("SSH_KEY", "~/.ssh/james-macmini"))

def ssh(cmd, timeout=10):
    try:
        r = subprocess.run(["/usr/bin/ssh", "-i", KEY, HOST, cmd], capture_output=True, timeout=timeout)
        return r.stdout + r.stderr
    except:
        return b""

def check(name, ok):
    print(f"{name}: {'OK' if ok else 'FAIL'}")
    return ok

print("OSC 52 Clipboard Diagnostic\n")

# Test 1: Direct OSC 52
b64 = base64.b64encode(b"TEST").decode()
out = ssh(f"printf '\\033]52;c;{b64}\\007'")
check("Direct OSC 52", b'\x1b]52' in out or b']52;c;' in out)

# Test 2: osc52-copy script exists
out2 = ssh("test -x ~/.local/bin/osc52-copy && echo OK")
check("osc52-copy script", b"OK" in out2)

# Test 3: tmux config
out3 = ssh("grep 'copy-pipe.*osc52' ~/.tmux.conf 2>/dev/null")
check("tmux y binding", b"osc52-copy" in out3)

# Test 4: set-clipboard off (we handle it ourselves)
out4 = ssh("grep 'set-clipboard off' ~/.tmux.conf 2>/dev/null")
check("set-clipboard off", b"set-clipboard off" in out4)
