# Guidelines

- **Git**: Do NOT auto-commit or stage changes unless explicitly requested by the user.
- **Breadcrumbs**: Where future readers need context, leave a link — vendor docs, issues, RFCs, related internal docs. Applies to code, markdown, configs, and commits. Skip when self-evident.
- **Markdown**: Use Mermaid for diagrams; avoid ASCII art.
- **TODO**: Log deferred items (fixes/improvements noticed mid-task) to `TODO.md`.

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

`meow-toolbox-just <recipe>` runs any meow-toolbox just recipe from anywhere (e.g. `meow-toolbox-just langpack-pull`).

`meow-doc-finder <query>` fuzzy-finds markdown docs across Meow Tower repos. Outputs env-var-prefixed paths with summaries.

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
| `build-unity-sln` | Unity solution compile check: `{ios,android}[,...] {editor,dev,prod}[,...]` (all combinations in parallel) |
| `md-orphan` | Markdown orphan/broken-link/anchor check |
