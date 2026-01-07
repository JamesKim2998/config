#!/usr/bin/env python3
"""sv() cd-on-exit diagnostic."""

import os
from config import ssh, ssh_grep, check

print("sv() cd-on-exit Diagnostic\n")

check("SSH connection", "OK" in ssh("echo OK")[0])
check("zshexit hook", ssh_grep("zshexit.*sv_last_dir", "~/.zshrc")[1])

path = ssh("cat ~/.sv_last_dir 2>/dev/null")[0].strip()
check("~/.sv_last_dir", bool(path), path or "(empty)")
if path:
    check("Local path exists", os.path.isdir(path))

print("\n--- Flow ---")
print("1. zshexit() saves pwd on shell exit")
print("2. sv() reads ~/.sv_last_dir and cd's locally")
