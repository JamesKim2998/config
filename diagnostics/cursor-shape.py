#!/usr/bin/env python3
"""Cursor shape escape sequence diagnostic for SSH/mosh + tmux setups.

Chain: Kitty (local) → mosh → tmux → zsh (server)
Each layer can block cursor escape sequences.
"""

import subprocess
import os
import sys

HOST = os.environ.get("SSH_HOST", "jameskim@192.168.219.122")
KEY = os.path.expanduser(os.environ.get("SSH_KEY", "~/.ssh/james-macmini"))

def ssh(cmd, timeout=10):
    try:
        r = subprocess.run(["/usr/bin/ssh", "-i", KEY, HOST, cmd],
                          capture_output=True, timeout=timeout, text=True)
        return r.stdout + r.stderr
    except Exception as e:
        return str(e)

def check(name, ok, note=""):
    status = "✓" if ok else "✗"
    suffix = f" — {note}" if note else ""
    print(f"  {status} {name}{suffix}")
    return ok

print("=" * 60)
print("Cursor Shape Diagnostic")
print("Chain: Kitty → mosh → tmux → zsh")
print("=" * 60)

# --- Config checks ---
print("\n[1] Config Files\n")

out1 = ssh("grep -q 'zle-keymap-select' ~/.zshrc && echo OK")
check("zle-keymap-select in .zshrc", "OK" in out1)

out2 = ssh("grep -q 'zle-line-init' ~/.zshrc && echo OK")
check("zle-line-init in .zshrc", "OK" in out2)

out3 = ssh("grep 'allow-passthrough' ~/.tmux.conf 2>/dev/null")
check("tmux allow-passthrough on", "allow-passthrough on" in out3)

# Check cursor escape format in zshrc
out4 = ssh(r"grep -o '\\\\e\[.*q' ~/.zshrc | head -1")
check("zsh cursor escape format", r"\e[" in out4, out4.strip() or "not found")

# --- Escape sequence tests ---
print("\n[2] Escape Sequence Output (run FROM SERVER, view in Kitty)\n")

print("  Test these commands inside your sv() session:\n")

print("  # Direct (no wrapping):")
print("  printf '\\e[2 q' && echo ' ← should be BLOCK'")
print("  printf '\\e[6 q' && echo ' ← should be BEAM'")

print("\n  # With tmux passthrough wrapper:")
print("  printf '\\ePtmux;\\e\\e[2 q\\e\\\\' && echo ' ← should be BLOCK'")
print("  printf '\\ePtmux;\\e\\e[6 q\\e\\\\' && echo ' ← should be BEAM'")

# --- Known issues ---
print("\n[3] Known Issues\n")

# Check mosh version (older versions have issues)
mosh_ver = ssh("mosh-server --version 2>&1 | head -1")
check("mosh-server version", "mosh" in mosh_ver.lower(), mosh_ver.strip())

# Check tmux version
tmux_ver = ssh("tmux -V")
check("tmux version", "tmux" in tmux_ver.lower(), tmux_ver.strip())

print("\n[4] Diagnosis\n")

print("""  KNOWN LIMITATION: Mosh 1.4.0 does NOT support cursor shape (DECSCUSR).
  See: https://github.com/mobile-shell/mosh/pull/1355

  Workarounds:
    1. Use SSH instead of mosh (cursor works, but no roaming)
    2. Build mosh from PR #1355 (adds cursor support)
    3. Live without cursor switching through mosh

  To verify mosh is the blocker:
    → Test via SSH (bypassing mosh) - if cursor works, mosh is the issue
""")

print("[5] Quick Test Commands\n")
print("  # Test via direct SSH (bypassing mosh):")
print(f"  ssh -i {KEY} {HOST}")
print("  printf '\\e[2 q'  # Should change to block")
print("")
print("  # Test via SSH + tmux (bypassing mosh):")
print(f"  ssh -i {KEY} {HOST} -t 'tmux new -A -s test'")
print("  printf '\\e[2 q'  # Should change to block")
