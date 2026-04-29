# Guidelines

## Workflow
- **Clarification**: When uncertain, ask before proceeding.
- **Git**: Do NOT auto-commit or stage changes unless explicitly requested by the user.
- **TODO**: Log deferred items (fixes/improvements noticed mid-task) to `TODO.md`.

## Authoring
Applies to code, docs, configs, and commit messages.
- **Breadcrumbs**: Where future readers need context, leave a link — vendor docs, issues, RFCs, related internal docs. Skip when self-evident.
- **File Headers**: Link to related docs (`// See [[foo.md]]`) instead of duplicating them. Cap at ~3 lines beyond the link; push longer content into the doc.

## Code
- **Error Handling**: Never silently swallow errors — throw or log. Prefer natural exception flow over catch-and-swallow.
- **Control Flow**: Prefer early return over nested conditionals.
- **Strong Types**: Avoid raw primitives for non-self-contained keys/IDs or primitives reused across call sites. C#: `enum : uint` (size to fit) for scalar keys (`CatType`, `InteriorIndex`), `struct` for composite keys (`InteriorKey`). TS: branded type `T & { __brand: 'X' }` (`AbsPath`).

---

# Documentation Policy

- **Domain over Implementation:** Document *what* and *why*. Skip internal API signatures, self-explanatory patterns, and temporary code.
- **Reference, Don't Repeat:** Each fact lives in one place — point to source/docs rather than duplicating. Don't enumerate source-discoverable items (enum members, subclass lists) — they go stale.
- **Progressive Disclosure:** Keep `CLAUDE.md` minimal; details belong in `docs/`.
- **Crosslink:** Start each doc with `> **Related:**` linking to related docs.
- **File References:** Filename only. Subfolder suffix if ambiguous. No full paths. Same-repo: wiki-link (`[[doc.md]]`, `[[doc.md#my-section]]` — anchor is kebab-case slug of heading). Cross-repo: backtick + repo suffix (`` `bar.md` `` (meow-some-repo)).
- **Diagrams:** Use Mermaid; avoid ASCII art.

---

# Development Environment

## Major Repositories

All repos live under `$MEOW_ROOT`.

| Repo | Env Var | Description |
|------|---------|-------------|
| **meow-tower** | `$MEOW_CLIENT` | Unity mobile game (iOS/Android) - main game project |
| **meow-assets** | `$MEOW_ASSETS` | Art, UI, sound, store, marketing assets |
| **meow-toolbox** | `$MEOW_TOOLBOX` | Bun/TS dev tools - PSD processing, spreadsheets, Firebase, App Store Connect, automation scripts |
| **meow-langpack** | `$MEOW_LANGPACK` | Game text — source files (KO + translations) |
| **meow-game-server** | `$MEOW_SERVER` | Backend for gameplay services |
| **meow-infra** | `$MEOW_INFRA` | OpenTofu infra - Route53 DNS, EC2 systemd units, Caddy, LFS relay |
| **meow-dev-media** | `$MEOW_DEV_MEDIA` | Thumbnails for Google Sheets; auto-synced to S3 (`meow-dev-media.studioboxcat.com`) via GitHub Actions |
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
| `build-unity-sln` | Unity solution compile check: `{ios,android,osx}[,...] {editor,dev,prod}[,...]` (all combinations in parallel) |
| `md-orphan` | Markdown orphan/broken-link/anchor check |
| `notion-to-md` | Notion page → md; bare image filenames (`$NOTION_IMG_CACHE`) |
