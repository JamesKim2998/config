#!/usr/bin/env python3
"""sv() cd-on-exit diagnostic for SSH setups."""

import os
from config import ssh, check

print("sv() cd-on-exit Diagnostic\n")

# Test 1: SSH connection
out, ok = ssh("echo OK")
check("SSH connection", "OK" in out)

# Test 2: trap in sv() function (local .zshrc)
import subprocess
result = subprocess.run(["grep", "-q", "trap.*sv_last_dir", f"{os.path.expanduser('~')}/.zshrc"], capture_output=True)
check("EXIT trap in sv()", result.returncode == 0)

# Test 3: ~/.sv_last_dir file exists and has content
out, _ = ssh("cat ~/.sv_last_dir 2>/dev/null")
path = out.strip()
check("~/.sv_last_dir file", bool(path), f"path={path}" if path else "empty/missing")

# Test 4: Local path exists
if path:
    import os
    exists = os.path.isdir(path)
    check("Local path exists", exists, path)

print("\n--- How it works ---")
print("1. sv() runs: trap 'pwd > ~/.sv_last_dir' EXIT")
print("2. On shell exit, current directory is saved")
print("3. After disconnect, sv() reads ~/.sv_last_dir and cd's locally")
