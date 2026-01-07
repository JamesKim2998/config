#!/usr/bin/env python3
"""sv() cd-on-exit diagnostic for SSH setups."""

import os
from config import ssh, ssh_grep, check

print("sv() cd-on-exit Diagnostic\n")

# Test 1: SSH connection
out, ok = ssh("echo OK")
check("SSH connection", "OK" in out)

# Test 2: zshexit hook in .zshrc (saves pwd on SSH exit)
_, ok = ssh_grep("zshexit.*sv_last_dir", "~/.zshrc")
check("zshexit hook in .zshrc", ok)

# Test 3: ~/.sv_last_dir file exists and has content
out, _ = ssh("cat ~/.sv_last_dir 2>/dev/null")
path = out.strip()
check("~/.sv_last_dir file", bool(path), f"path={path}" if path else "empty/missing")

# Test 4: Local path exists
if path:
    exists = os.path.isdir(path)
    check("Local path exists", exists, path)

print("\n--- How it works ---")
print("1. .zshrc defines: zshexit() { pwd > ~/.sv_last_dir }")
print("2. On shell exit, zsh calls zshexit and saves current directory")
print("3. After disconnect, sv() reads ~/.sv_last_dir and cd's locally")
