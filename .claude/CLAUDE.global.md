# Guidelines

## Workflow
- **Git**: Do NOT auto-commit or stage changes unless explicitly requested by the user.
- **Commit Scope**: Agents share the worktree — commit your own files only (`git commit --only <files>`).
- **TODO**: Log out-of-scope items (pain points, architectural friction, tech debt, slow tests, weak infra) to the nearest `TODO.md`. If it bears on the current task, fix it now instead.

## Authoring
Applies to code, docs, configs, and commit messages.
- **Minimal**: Only what the code can't say. No restating, no filler, no history ("used to…", "previously…") — describe current behavior only.
- **Single Source**: One home per fact — logic in code, rationale in comments, domain in docs. Link, don't copy.
- **No Enumeration**: Don't list source-discoverable items (enum members, subclass lists) — they go stale.
- **Implementation Rationale**: "Why this over alternatives" for a local decision lives as a line comment on the code embodying it.
- **Breadcrumbs**: Where future readers need context, leave a link — vendor docs, issues, RFCs, related internal docs, the harness enforcing a rule. Skip when self-evident.
- **File Headers**: Link to related docs (`// See [[foo.md]]`); cap at ~3 lines beyond the link, push longer content into the doc.

## Code
- **Error Handling**: Never silently swallow errors — throw or log. Prefer natural exception flow over catch-and-swallow.
- **Control Flow**: Prefer early return over nested conditionals.
- **Strong Types**: Avoid raw primitives for keys/IDs and values reused across call sites — wrap them in an enum, struct, or branded type.

## Docs
- **Domain over Implementation**: Skip internal API signatures and temporary code.
- **Progressive Disclosure**: Keep `CLAUDE.md` minimal; details belong in `docs/`.
- **Harness over Rules**: Enforce with a hook, lint rule, type, or test; write a doc rule only when nothing can check it.
- **Related Header**: Start each doc with `> **Related:**`. Per-link note okay, but no self-explaining.
- **File References**: Filename only, no full paths; subfolder suffix if ambiguous. Same folder: `[[doc.md]]`, `[[doc.md#section]]`. Another monorepo folder or an external repo: `` `bar.md` (folder-or-repo) ``.
- **Diagrams**: Use Mermaid; avoid ASCII art.

---

# Development Environment

## Major Repositories

The studio's tools, services and games are one monorepo, `studio-boxcat/boxcat`, whose main clone is `$BOXCAT_ROOT` (`~/Develop/boxcat`). Each top-level folder is a former repo with its own `CLAUDE.md`; the few external repos (roster: `repos.json`, boxcat-devenv) sit beside it under `~/Develop`.

| Folder | Path | Description |
|------|---------|-------------|
| **meow-tower** | `$BOXCAT_ROOT/meow-tower` | Unity mobile game (iOS/Android) - main game project |
| **meow-assets** | `$BOXCAT_ROOT/meow-assets` | Art, UI, sound, store, marketing assets |
| **meow-toolbox** | `$BOXCAT_ROOT/meow-toolbox` | Bun/TS dev tools - PSD processing, spreadsheets, Firebase, App Store Connect, automation scripts |
| **boxcat-rust-tools** | `$BOXCAT_ROOT/boxcat-rust-tools` | Rust monorepo for meow-ecosystem tooling - per-domain CLIs/rlibs + C FFI / napi bridges. Hub: `CLAUDE.md` (boxcat-rust-tools) |
| **pspec** | `$BOXCAT_ROOT/pspec` | Rust CLI - Unity `.prefab`/`.unity`/`.asset` ↔ JSON. Hub: `CLAUDE.md` (pspec) |
| **meow-langpack** | `$BOXCAT_ROOT/meow-langpack` | Game text — source files (KO + translations) |
| **meow-game-server** | `$BOXCAT_ROOT/meow-game-server` | Backend for gameplay services |
| **meow-infra** | `$BOXCAT_ROOT/meow-infra` | OpenTofu infra - Route53 DNS, EC2 systemd units, Caddy, LFS relay |
| **meow-dev-media** | `$BOXCAT_ROOT/meow-dev-media` | Thumbnails for Google Sheets; auto-synced to S3 (`meow-dev-media.studioboxcat.com`) via GitHub Actions |
| **config** (external) | `$CONFIG_REPO` | macOS dotfiles - nvim, kitty, zsh, git, yazi, lazygit, hammerspoon |

`boxcat-*` folders: shared TS packages, consumed as `workspace:*` deps. Code finds a sibling folder in its own clone (`repoDir`), never through an env var.

`boxcat-devenv <verb>` sets up and syncs this host — `bootstrap`, `doctor`, `sync`, `where` (`--help` for the rest). Hub: `CLAUDE.md` (boxcat-devenv).

`meow-toolbox-just <recipe>` runs any meow-toolbox just recipe from anywhere (e.g. `meow-toolbox-just langpack-sheet pull`).

`boxcat-doc <query>` fuzzy-finds docs across the main clone's folders and the external clones — `$BOXCAT_ROOT/<folder>/…` paths with summaries.

## CLI Tools

| Command | Description |
|---------|-------------|
| `ilspycmd` | .NET decompiler CLI |
| `unity-solution-generator typecheck .` | Unity solution compile check; defaults to `ios editor`, override with `... <platform> <config>` |
| `unity-launcher` | Unity editor launcher: `launch [-batchmode]` / `focus` / `quit`. Walks up from the binary or cwd looking for `ProjectSettings/`. |
| `unity-assetdb` | Unity asset GUID ↔ path/name index. Query with `guid` / `path` / `find` / `alias` / `usage`. |
| `unity-asmdef` | Unity assembly index. Query with `which` (file → assembly) / `info` / `deps`. JSON out. |
| `pspec` | Unity `.prefab`/`.unity`/`.asset` ↔ JSON |
| `upextract` | `.unitypackage` extractor |
| `game-art-tool` | PSD/AI parsing, layer export, TexturePacker ops |
| `langpack` | Langpack compiler + query/authoring CLI. Source at `$BOXCAT_ROOT/meow-langpack` |
| `ntn` | Notion CLI (`ntn --help`) |

Also preinstalled: `aws`, `fd`, `ffmpeg`, `firebase`, `gcloud`, `gh`, `hyperfine`, `jq`, `just`, `magick`, `mlr`, `optipng`, `ouch`, `parallel`, `pngquant`, `rg`, `sd`, `tofu`, `yq`.
