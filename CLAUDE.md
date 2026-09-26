# Config Repository

> **Related:** `CLAUDE.md` (boxcat-devenv) — the repos, once the machine is set up

macOS dotfiles and development environment configuration.

## Structure

| Tool | Config | Desc |
|------|--------|------|
| Neovim | [[nvim.md|nvim/]] | IDE with Lazy.nvim plugin manager |
| Kitty | `kitty/` | Terminal emulator, Kanagawa theme |
| Git | `git/` | Config with delta diff viewer |
| Yazi | [[yazi.md|yazi/]] | File manager with plugins |
| Lazygit | `lazygit/` | Git TUI |
| Bat | `bat/` | Syntax-highlighted cat |
| Hammerspoon | [[README.md|.hammerspoon/]] | Window management, app launcher hotkeys (`U` shells out to [`unity-launcher`](https://github.com/studio-boxcat/unity-launcher) for meow-tower) |
| IntelliJ | `intellij/` | IdeaVim (.ideavimrc), Copilot settings |
| Gemini | `gemini/` | Gemini CLI |
| VS Code | [[vscode.md|vscode/]] | Global editor settings (symlinked to `Code/User/`); `.vscode/` is this repo's own workspace layer |
| Zsh | `.zshenv`, `.zshrc` | Shell config |
| Starship | `starship.toml` | Prompt |
| Karabiner | [[README.md|karabiner/]] | Keyboard remapping (manual sync via justfile) |
| Cargo | `.cargo/` | Local-checkout patches for in-house Rust crates (per-machine) |
| Tailscale | [[TAILSCALE.md|tailscale/]] | Mesh VPN; LaunchDaemon healing the LG U+ CGNAT route collision |

## Shell Config

| File | When Sourced | Contents |
|------|--------------|----------|
| `.zshenv` | ALL shells (login, interactive, scripts, subshells) | PATH, the env boxcat-devenv generates (`~/.config/boxcat/env.zsh`), then `.zshenv.local` |
| `.zshenv.local` | All shells (not tracked) | SSH agent, secrets, machine-specific overrides — not repo paths, those are boxcat-devenv's |
| `.zshrc` | Interactive shells only | Aliases, functions, completions, prompt |

The mac mini is the server because the monorepo's root `.boxcat.env.json` names its `LocalHostName`
(`server.ts`, boxcat-devenv); nothing in the shell marks it. `setup-server.sh` only sets its look and
the mirror root in `~/.zshenv.local`.

Note: PATH must be in `.zshenv` for subshell compatibility (e.g., `$(...)`, pipes, xargs).

See [[diagnostics/shell-path.test.ts]] for PATH validation and zsh gotchas.

## Theme

| Environment | Theme | Control |
|-------------|-------|---------|
| Local (dark) | Kanagawa | Default |
| Local (light) | Kanagawa Lotus | Auto-switched by kitty via `{dark,light}-theme.auto.conf` on macOS appearance change |
| Server | Tokyo Night | `setup-server.sh` |
| SSH window | Tokyo Night | `sv` function in `.zshrc` |

Themed: nvim, kitty, lazygit, bat, yazi, starship, delta

## Setup

| Script | Desc |
|--------|------|
| `setup.sh` | Brew packages and casks (grouped by inline comments), bun, rustup, cargo tools, symlinks, the global env |
| `setup-server.sh` | Server-only shell env (`GITHUB_MIRROR_ROOT`), Tokyo Night |
| `diagnostics/` | SSH, clipboard, nvim, yazi diagnostics |

Run diagnostics with `cd diagnostics && bun test`.

The repos come after the machine: `just bootstrap` in boxcat-devenv clones and links them.

Deferred follow-ups: [[TODO.md]].
