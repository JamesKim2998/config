# Guidelines

## Git
- Do NOT auto-commit or stage changes unless explicitly requested by the user.

## Doc Guidelines
- While working, log any misleading docs, outdated instructions, own mistakes, or improvement opportunities to `TODO.md`.
- Use Mermaid for diagrams in Markdown. Avoid ASCII art.

---

# Development Environment

## Major Repositories

All repos live under `$MEOW_ROOT`.

| Repo | Env Var | Description |
|------|---------|-------------|
| **meow-tower** | `$MEOW_CLIENT` | Unity mobile game (iOS/Android) - main game project |
| **meow-assets** | `$MEOW_ASSETS` | Art, UI, sound, store, marketing assets |
| **meow-toolbox** | `$MEOW_TOOLBOX` | Bun/TS dev tools - PSD processing, spreadsheets, Firebase, App Store Connect, automation scripts |
| **alfredo** | `$ALFREDO_REPO` | Personal assistant - Slack bot, Notion, Gmail, AWS/GCS, pm2 services |
| **config** | `$CONFIG_REPO` | macOS dotfiles - nvim, kitty, zsh, git, yazi, lazygit, hammerspoon |

## CLI Tools

| Command | Description |
|---------|-------------|
| `fd` | Fast file finder (find alternative) |
| `sd` | Fast find & replace (sed alternative) |
| `parallel` | Run commands in parallel |
| `jq` | |
| `mlr` | CSV/TSV/JSON record processing |
| `magick` | |
| `ffmpeg` | |
| `just` | Make like task runner |
| `gh` | |
| `ilspycmd` | .NET decompiler CLI |
