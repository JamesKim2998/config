#!/usr/bin/env python3
"""Cursor shape escape sequence diagnostic for SSH/mosh + tmux setups."""

import subprocess
import os

HOST = os.environ.get("SSH_HOST", "jameskim@192.168.219.122")
KEY = os.path.expanduser(os.environ.get("SSH_KEY", "~/.ssh/james-macmini"))

def ssh(cmd, timeout=10):
    try:
        r = subprocess.run(["/usr/bin/ssh", "-i", KEY, HOST, cmd], capture_output=True, timeout=timeout)
        return (r.stdout + r.stderr).decode()
    except:
        return ""

def check(name, ok, note=""):
    status = "OK" if ok else "FAIL"
    suffix = f" ({note})" if note else ""
    print(f"{name}: {status}{suffix}")
    return ok

print("Cursor Shape Diagnostic (SSH + tmux)\n")

# Test 1: zle cursor functions exist
out1 = ssh("grep -q 'zle-keymap-select' ~/.zshrc && echo OK")
check("zle-keymap-select in .zshrc", "OK" in out1)

# Test 2: zle-line-init exists
out2 = ssh("grep -q 'zle-line-init' ~/.zshrc && echo OK")
check("zle-line-init in .zshrc", "OK" in out2)

# Test 3: tmux allow-passthrough (required for cursor escapes through tmux)
out3 = ssh("grep 'allow-passthrough' ~/.tmux.conf 2>/dev/null")
check("tmux allow-passthrough", "allow-passthrough on" in out3,
      "REQUIRED for cursor escapes through tmux")

# Test 4: TERM set correctly
out4 = ssh("tmux show -gv default-terminal 2>/dev/null || echo not-set")
check("tmux default-terminal", "256color" in out4, out4.strip())

# Test 5: escape-time is 0 (for responsive mode switching)
out5 = ssh("grep 'escape-time 0' ~/.tmux.conf 2>/dev/null")
check("tmux escape-time 0", "escape-time 0" in out5)

print("\n--- Escape sequence test ---")
print("Run these inside tmux on the server:")
print("  Block:  printf '\\e[2 q'")
print("  Beam:   printf '\\e[6 q'")
print("If cursor doesn't change, allow-passthrough is the issue.")
