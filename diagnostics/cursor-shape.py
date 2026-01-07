#!/usr/bin/env python3
"""Cursor shape escape sequence diagnostic for SSH setups.

Chain: Kitty (local) → SSH → zsh (server)
"""

from config import ssh, ssh_grep, check, MACMINI_DEST, MACMINI_SSH_KEY

print("=" * 60)
print("Cursor Shape Diagnostic")
print("Chain: Kitty → SSH → zsh")
print("=" * 60)

# --- Config checks ---
print("\n[1] Config Files\n")

_, ok = ssh_grep("zle-keymap-select", "~/.zshrc", quiet=True)
check("zle-keymap-select in .zshrc", ok)

_, ok = ssh_grep("zle-line-init", "~/.zshrc", quiet=True)
check("zle-line-init in .zshrc", ok)

out, _ = ssh(r"grep -o '\\e\[.*q' ~/.zshrc | head -1")
check("zsh cursor escape format", r"\e[" in out, out.strip() or "not found")

# --- Escape sequence tests ---
print("\n[2] Escape Sequence Output (run FROM SERVER, view in Kitty)\n")

print("  Test these commands inside your sv() session:\n")

print("  printf '\\e[2 q' && echo ' ← should be BLOCK'")
print("  printf '\\e[6 q' && echo ' ← should be BEAM'")

print("\n[3] Quick Test Commands\n")
print("  # Test via SSH:")
print(f"  ssh -i {MACMINI_SSH_KEY} {MACMINI_DEST}")
print("  printf '\\e[2 q'  # Should change to block")
