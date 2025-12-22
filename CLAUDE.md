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

## Brew Packages

| Category | Packages |
|----------|----------|
| Editor | nvim |
| Search & find | fzf, rg, fd |
| File viewing & data processing | bat, jq, yq, sd |
| File navigation & listing | eza, lsd, zoxide, yazi |
| System utilities | clipboard, procs, httpie |
| Compression & archives | 7-zip, ouch |
| Media processing | imagemagick, ffmpeg |
| Git tools | lazygit, delta, git-lfs, gh, copilot |
| Languages & runtimes | lua, rust, go, node, bun, dotnet |
| Cloud & CLI tools | gemini-cli, awscli |
| Task runner & shell | just, starship |
| Casks | libreoffice, docker |

## Cargo Packages

| Package | Purpose |
|---------|---------|
| stylua | Lua code formatter |
| selene | Lua linter |

## Symlink Targets

| Source | Target |
|--------|--------|
| `.zshrc` | `~/.zshrc` |
| `starship.toml` | `~/.config/starship.toml` |
| `.ripgreprc` | `~/.ripgreprc` |
| `git/.gitconfig` | `~/.gitconfig` |
| `git/.gitignore_global` | `~/.gitignore_global` |
| `nvim/` | `~/.config/nvim` |
| `kitty/` | `~/.config/kitty` |
| `yazi/` | `~/.config/yazi` |
| `bat/` | `~/.config/bat` |
| `lsd/` | `~/.config/lsd` |
| `lazygit/` | `~/Library/Application Support/lazygit` |
| `karabiner.json` | `~/.config/karabiner/karabiner.json` |
| `.hammerspoon/` | `~/.hammerspoon` |
| `gemini/` | `~/.gemini` |
| `.vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json` |

## Theme

Catppuccin Mocha is used consistently across nvim, kitty, bat, and fzf.

## Setup

```sh
./setup.sh
```
