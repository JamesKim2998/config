# Config Repository

macOS dotfiles and development environment configuration.

## Structure

| Tool | Config | Desc |
|------|--------|------|
| Neovim | [`nvim/`](docs/nvim.md) | IDE with Lazy.nvim plugin manager |
| Kitty | `kitty/` | Terminal emulator, Kanagawa theme |
| Git | `git/` | Config with delta diff viewer |
| Yazi | `yazi/` | File manager with plugins |
| Lazygit | `lazygit/` | Git TUI |
| Bat | `bat/` | Syntax-highlighted cat |
| Hammerspoon | [`.hammerspoon/`](.hammerspoon/README.md) | Window management, app launcher hotkeys |
| IntelliJ | `intellij/` | IdeaVim (.ideavimrc), Copilot settings |
| Gemini | `gemini/` | Gemini CLI |
| VS Code | `.vscode/` | Editor settings |
| Zsh | `.zshenv`, `.zshrc` | Shell config |
| Starship | `starship.toml` | Prompt |
| Ripgrep | `.ripgreprc` | Search settings |
| Karabiner | [`karabiner/`](karabiner/README.md) | Keyboard remapping (manual sync via justfile) |

## Shell Config

| File | When Sourced | Contents |
|------|--------------|----------|
| `.zshenv` | ALL shells (login, interactive, scripts, subshells) | PATH, env vars, sources `.zshenv.local` |
| `.zshenv.local` | All shells (not tracked) | SSH agent, machine-specific overrides |
| `.zshrc` | Interactive shells only | Aliases, functions, completions, prompt |

Note: PATH must be in `.zshenv` for subshell compatibility (e.g., `$(...)`, pipes, xargs).

See [`diagnostics/shell-path.test.ts`](diagnostics/shell-path.test.ts) for PATH validation and zsh gotchas.

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
| Shell tools | just, starship, shellcheck, zsh-autosuggestions |
| Casks | kitty, hammerspoon, libreoffice, font-hack-nerd-font, tailscale, gureumkim |

## Theme

| Environment | Theme | Control |
|-------------|-------|---------|
| Local | Kanagawa | Default |
| Server | Tokyo Night | `setup-server.sh` |
| SSH window | Tokyo Night | `sv` function in `.zshrc` |

Themed: nvim, kitty, lazygit, bat, yazi, starship, delta

## Setup

| Script | Desc |
|--------|------|
| `setup.sh` | Homebrew, CLI tools, symlinks |
| `setup-server.sh` | Server-specific setup (Tokyo Night) |
| `diagnostics/` | SSH, clipboard, nvim plugin diagnostics |

Run diagnostics with `cd diagnostics && bun test`.
