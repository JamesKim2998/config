import { consola } from "consola";
import { ssh, sshGrep, check, header, section, MACMINI_DEST, MACMINI_SSH_KEY } from "./lib";

header("Cursor Shape Diagnostic\nChain: Kitty → SSH → zsh");

section(1, "Config Files");
check("zle-keymap-select in .zshrc", await sshGrep("zle-keymap-select", "~/.zshrc"));
check("zle-line-init in .zshrc", await sshGrep("zle-line-init", "~/.zshrc"));

const escapeFormat = await ssh("grep -o '\\\\e\\[.*q' ~/.zshrc | head -1");
check("zsh cursor escape format", escapeFormat.includes("\\e["), escapeFormat.trim() || "not found");

section(2, "Escape Sequence Tests");
console.log("  Test in sv() session:\n");
console.log("  printf '\\e[2 q' && echo ' ← BLOCK'");
console.log("  printf '\\e[6 q' && echo ' ← BEAM'");

section(3, "Quick Test");
console.log(`  ssh -i ${MACMINI_SSH_KEY} ${MACMINI_DEST}`);
console.log("  printf '\\e[2 q'  # Should change to block");
