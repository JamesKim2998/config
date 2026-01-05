# Config Repository

macOS dotfiles and development environment configuration.

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `nvim/` | Neovim IDE configuration with Lazy.nvim plugin manager |
| `kitty/` | Kitty terminal emulator settings and Tokyo Night theme |
| `git/` | Git configuration with delta diff viewer |
| `yazi/` | Terminal file manager with plugins and keybindings |
| `lazygit/` | Git TUI configuration |
| `bat/` | Syntax-highlighted cat replacement |
| `.hammerspoon/` | macOS window management and app launcher hotkeys |
| `intellij/` | IntelliJ IDE and Copilot settings |
| `gemini/` | Gemini CLI configuration |
| `.vscode/` | VS Code settings |

## Root Configuration Files

| File | Purpose |
|------|---------|
| `.zshrc` | Shell config with PATH, aliases, and tool initialization |
| `setup.sh` | Installation script for Homebrew, CLI tools, and symlinks |
| `starship.toml` | Starship prompt configuration (Tokyo Night) |
| `.ripgreprc` | Ripgrep search settings |
| `karabiner.json` | Keyboard remapping (Caps Lock to Escape, etc.) |

## Brew Packages

| Category | Packages |
|----------|----------|
| Editor | nvim |
| Search & find | fzf, rg, fd |
| File viewing & data processing | bat, jq, yq, sd, glow, miller |
| File navigation & listing | eza, zoxide, yazi, tree |
| Yazi previews | ffmpegthumbnailer, poppler, exiftool, mediainfo, pandoc |
| System utilities | clipboard, procs, httpie, wget |
| Compression & archives | 7-zip, ouch |
| Media processing | imagemagick, ffmpeg |
| Git tools | lazygit, delta, git-lfs, gh, copilot |
| Languages & runtimes | lua, rust, go, node, bun, dotnet |
| Cloud & CLI tools | gemini-cli, awscli |
| Shell tools | just, starship, shellcheck, mosh, atuin |
| Casks | libreoffice, docker, font-hack-nerd-font |

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
