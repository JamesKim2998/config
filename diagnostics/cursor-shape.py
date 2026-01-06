#!/usr/bin/env python3
"""Cursor shape escape sequence diagnostic for SSH/mosh + tmux setups.

Chain: Kitty (local) → mosh → tmux → zsh (server)
Each layer can block cursor escape sequences.
"""

from config import ssh, ssh_grep, check, MACMINI_DEST, MACMINI_SSH_KEY

print("=" * 60)
print("Cursor Shape Diagnostic")
print("Chain: Kitty → mosh → tmux → zsh")
print("=" * 60)

# --- Config checks ---
print("\n[1] Config Files\n")

_, ok = ssh_grep("zle-keymap-select", "~/.zshrc", quiet=True)
check("zle-keymap-select in .zshrc", ok)

_, ok = ssh_grep("zle-line-init", "~/.zshrc", quiet=True)
check("zle-line-init in .zshrc", ok)

out, ok = ssh_grep("allow-passthrough", "~/.tmux.conf")
check("tmux allow-passthrough on", "allow-passthrough on" in out)

out, _ = ssh(r"grep -o '\\e\[.*q' ~/.zshrc | head -1")
check("zsh cursor escape format", r"\e[" in out, out.strip() or "not found")

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

out, _ = ssh("mosh-server --version 2>&1 | head -1")
check("mosh-server version", "mosh" in out.lower(), out.strip())

out, _ = ssh("tmux -V")
check("tmux version", "tmux" in out.lower(), out.strip())

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
print(f"  ssh -i {MACMINI_SSH_KEY} {MACMINI_DEST}")
print("  printf '\\e[2 q'  # Should change to block")
print("")
print("  # Test via SSH + tmux (bypassing mosh):")
print(f"  ssh -i {MACMINI_SSH_KEY} {MACMINI_DEST} -t 'tmux new -A -s test'")
print("  printf '\\e[2 q'  # Should change to block")
