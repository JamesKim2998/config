# Guidelines

## Workflow
- **Git**: Do NOT auto-commit or stage changes unless explicitly requested by the user.
- **TODO**: Log out-of-scope items to the nearest `TODO.md`.

## Authoring
Applies to code, docs, configs, and commit messages.
- **Minimal**: Only what the code can't say. No restating, no filler, no history ("used to…", "previously…") — describe current behavior only.
- **Single Source**: One home per fact — logic in code, rationale in comments, domain in docs. Link, don't copy.
- **No Enumeration**: Don't list source-discoverable items (enum members, subclass lists) — they go stale.
- **Implementation Rationale**: "Why this over alternatives" for a local decision lives as a line comment on the code embodying it.
- **Breadcrumbs**: Where future readers need context, leave a link — vendor docs, issues, RFCs, related internal docs. Skip when self-evident.
- **File Headers**: Link to related docs (`// See [[foo.md]]`); cap at ~3 lines beyond the link, push longer content into the doc.

## Code
- **Error Handling**: Never silently swallow errors — throw or log. Prefer natural exception flow over catch-and-swallow.
- **Control Flow**: Prefer early return over nested conditionals.
- **Strong Types**: Avoid raw primitives for keys/IDs and values reused across call sites — wrap them in an enum, struct, or branded type.

## Docs
- **Domain over Implementation**: Skip internal API signatures and temporary code.
- **Progressive Disclosure**: Keep `CLAUDE.md` minimal; details belong in `docs/`.
- **Crosslink**: Start each doc with `> **Related:**` linking to related docs.
- **File References**: Filename only. Subfolder suffix if ambiguous. No full paths. Same-repo: wiki-link (`[[doc.md]]`, `[[doc.md#my-section]]` — anchor is kebab-case slug of heading). Cross-repo: backtick + repo suffix (`` `bar.md` `` (meow-some-repo)).
- **Diagrams**: Use Mermaid; avoid ASCII art.

---

# Development Environment

## Major Repositories

All repos live under `$MEOW_ROOT`.

| Repo | Env Var | Description |
|------|---------|-------------|
| **meow-tower** | `$MEOW_CLIENT` | Unity mobile game (iOS/Android) - main game project |
| **meow-assets** | `$MEOW_ASSETS` | Art, UI, sound, store, marketing assets |
| **meow-toolbox** | `$MEOW_TOOLBOX` | Bun/TS dev tools - PSD processing, spreadsheets, Firebase, App Store Connect, automation scripts |
| **boxcat-rust-tools** | `$MEOW_ROOT/boxcat-rust-tools` | Rust monorepo for meow-ecosystem tooling - per-domain CLIs/rlibs + C FFI / napi bridges. Hub: `CLAUDE.md` (boxcat-rust-tools) |
| **pspec** | `$MEOW_ROOT/pspec` | Rust CLI - Unity `.prefab`/`.unity`/`.asset` ↔ JSON. Hub: `CLAUDE.md` (pspec) |
| **meow-langpack** | `$MEOW_LANGPACK` | Game text — source files (KO + translations) |
| **meow-game-server** | `$MEOW_SERVER` | Backend for gameplay services |
| **meow-infra** | `$MEOW_INFRA` | OpenTofu infra - Route53 DNS, EC2 systemd units, Caddy, LFS relay |
| **meow-dev-media** | `$MEOW_DEV_MEDIA` | Thumbnails for Google Sheets; auto-synced to S3 (`meow-dev-media.studioboxcat.com`) via GitHub Actions |
| **config** | `$CONFIG_REPO` | macOS dotfiles - nvim, kitty, zsh, git, yazi, lazygit, hammerspoon |

`meow-toolbox-just <recipe>` runs any meow-toolbox just recipe from anywhere (e.g. `meow-toolbox-just langpack-pull`).

`meow-doc-finder <query>` fuzzy-finds markdown docs across Meow Tower repos. Outputs env-var-prefixed paths with summaries.

## CLI Tools

| Command | Description |
|---------|-------------|
| `ilspycmd` | .NET decompiler CLI |
| `unity-solution-generator typecheck .` | Unity solution compile check; defaults to `ios editor`, override with `... <platform> <config>` |
| `unity-launcher` | Unity editor launcher: `launch [-batchmode]` / `focus` / `quit`. Walks up from the binary or cwd looking for `ProjectSettings/`. |
| `unity-assetdb` | Unity asset GUID ↔ path/name index. Query with `guid` / `path` / `find` / `alias` / `usage`. |
| `pspec` | Unity `.prefab`/`.unity`/`.asset` ↔ JSON |
| `game-art-tool` | PSD/AI parsing, layer export, TexturePacker ops |
| `langpack` | Langpack compiler + query/authoring CLI. Source at `$MEOW_LANGPACK` |
| `notion-to-md` | Notion page → md; bare image filenames (`$NOTION_IMG_CACHE`) |

Also preinstalled: `fd`, `ffmpeg`, `gh`, `jq`, `just`, `magick`, `mlr`, `parallel`, `sd`.
