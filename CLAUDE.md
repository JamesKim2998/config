# Config Repository

macOS dotfiles and development environment configuration.

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `nvim/` | Neovim IDE configuration with Lazy.nvim plugin manager |
| `kitty/` | Kitty terminal emulator settings and Kanagawa theme |
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
| `setup-server.sh` | Server-specific setup (Tokyo Night theme) |
| `starship.toml` | Starship prompt configuration |
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
| Shell tools | just, starship, shellcheck, mosh, tmux, zsh-autosuggestions |
| Casks | libreoffice, docker, font-hack-nerd-font, tailscale |

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

| Environment | Theme | Control |
|-------------|-------|---------|
| Local | Kanagawa | Default |
| Server | Tokyo Night | `setup-server.sh` |
| SSH window | Tokyo Night | `sv` function in `.zshrc` |

## Setup

### Local

```sh
./setup.sh
```

### Server (Mac Mini)

Run after `setup.sh`. Applies Tokyo Night theme and sets env vars.

```sh
./setup-server.sh
```

### Tailscale

Mesh VPN for stable Mac Mini access. Install on both machines and log in with same account.

```sh
brew install --cask tailscale
```

| Domain | Usage |
|--------|-------|
| `macmini.studioboxcat.com` | SSH, MACMINI_HOST env var |
| `lfs.studioboxcat.com` | Git LFS |
