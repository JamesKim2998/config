#!/usr/bin/env python3
"""Diagnostic for sv() cd-on-exit functionality."""

import subprocess
import os

HOST = "jameskim@192.168.219.122"
KEY = os.path.expanduser("~/.ssh/james-macmini")

def ssh(cmd, timeout=10):
    try:
        r = subprocess.run(["/usr/bin/ssh", "-i", KEY, HOST, cmd], capture_output=True, timeout=timeout)
        return r.stdout.decode().strip(), r.stderr.decode().strip(), r.returncode
    except Exception as e:
        return "", str(e), 1

def check(name, ok, detail=""):
    status = "OK" if ok else "FAIL"
    print(f"{name}: {status}")
    if detail:
        print(f"  -> {detail}")
    return ok

print("sv() cd-on-exit Diagnostic\n")

# Test 1: SSH connection
out, err, code = ssh("echo OK")
check("SSH connection", code == 0 and "OK" in out)

# Test 2: tmux client-detached hook in config
out, err, code = ssh("grep 'client-detached' ~/.tmux.conf")
check("tmux client-detached hook", "sv_last_dir" in out)

# Test 3: ~/.sv_last_dir exists
out, err, code = ssh("cat ~/.sv_last_dir 2>/dev/null")
saved_path = out
check("~/.sv_last_dir file", bool(saved_path), f"path={saved_path or '(empty - detach once to create)'}")

# Test 4: Local path exists
if saved_path:
    exists = os.path.isdir(saved_path)
    check("Local path exists", exists, saved_path)

print("\n--- How it works ---")
print("1. tmux saves pane path to ~/.sv_last_dir on detach (Ctrl+a d)")
print("2. sv() reads this file after disconnect and cd's locally")
print("Note: Only works with detach, not exit")
