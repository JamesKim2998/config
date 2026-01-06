#!/usr/bin/env python3
"""Diagnostic for sv() cd-on-exit functionality."""

import os
from config import ssh, ssh_grep, check

print("sv() cd-on-exit Diagnostic\n")

# Test 1: SSH connection
out, code = ssh("echo OK")
check("SSH connection", code == 0 and "OK" in out)

# Test 2: tmux client-detached hook in config
out, _ = ssh_grep("client-detached", "~/.tmux.conf")
check("tmux client-detached hook", "sv_last_dir" in out)

# Test 3: ~/.sv_last_dir exists
out, _ = ssh("cat ~/.sv_last_dir 2>/dev/null")
saved_path = out.strip()
check("~/.sv_last_dir file", bool(saved_path), f"path={saved_path or '(empty - detach once to create)'}")

# Test 4: Local path exists
if saved_path:
    exists = os.path.isdir(saved_path)
    check("Local path exists", exists, saved_path)

print("\n--- How it works ---")
print("1. tmux saves pane path to ~/.sv_last_dir on detach (Ctrl+a d)")
print("2. sv() reads this file after disconnect and cd's locally")
print("Note: Only works with detach, not exit")
