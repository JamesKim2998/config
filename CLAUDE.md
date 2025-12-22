# Config Repository

macOS dotfiles and development environment configuration.

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `nvim/` | Neovim IDE configuration with Lazy.nvim plugin manager |
| `kitty/` | Kitty terminal emulator settings and Catppuccin theme |
| `git/` | Git configuration with delta diff viewer |
| `yazi/` | Terminal file manager with plugins and keybindings |
| `lazygit/` | Git TUI configuration |
| `bat/` | Syntax-highlighted cat replacement |
| `lsd/` | Modern ls replacement with icons |
| `.hammerspoon/` | macOS window management and app launcher hotkeys |
| `intellij/` | IntelliJ IDE and Copilot settings |
| `gemini/` | Gemini CLI configuration |
| `.vscode/` | VS Code settings |

## Root Configuration Files

| File | Purpose |
|------|---------|
| `.zshrc` | Shell config with PATH, aliases, and tool initialization |
| `setup.sh` | Installation script for Homebrew, CLI tools, and symlinks |
| `starship.toml` | Starship prompt configuration |
| `.ripgreprc` | Ripgrep search settings |
| `karabiner.json` | Keyboard remapping (Caps Lock to Escape, etc.) |

## Theme

Catppuccin Mocha is used consistently across nvim, kitty, bat, and fzf.

## Setup

```sh
./setup.sh
```
