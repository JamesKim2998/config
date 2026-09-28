# Guidelines

## Communication
Applies to chat responses; written artifacts follow Authoring.
- **Non-Programmer Tone**: Explain to someone who doesn't code — plain words, and a short gloss for jargon that can't be avoided.
- **Result First**: Lead with what changed and what it means; mechanism after, only as deep as the reader needs.
- **Names Aren't Explanations**: A path or symbol points at the thing — still say what it does in words.

## Workflow
- **Git**: Do NOT auto-commit or stage changes unless explicitly requested by the user.
- **Commit Scope**: Agents share the worktree — commit your own files only (`git commit --only <files>`).
- **TODO**: Log out-of-scope friction (tech debt, slow tests, weak infra) in the repo's TODO, only when you can name the commit that deletes it. If it bears on the current task, fix it now instead.

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
- **Description**: A doc's frontmatter `description` states its scope; one that won't fit is two docs.
- **File References**: Filename only, no full paths; root-relative path only if the basename is ambiguous. Within a repo: `[[doc.md]]`, `[[doc.md#Heading Text]]` (the heading as written, not its slug). Another repo: `` `bar.md` (repo) ``.
- **Diagrams**: Use Mermaid; avoid ASCII art.

---

# Development Environment

Studio Boxcat's tools, services and games are one monorepo, `studio-boxcat/boxcat`, cloned at `$BOXCAT_ROOT` (`~/Develop/boxcat`); its root `CLAUDE.md` maps the folders and the commands it puts on PATH. These dotfiles are `$CONFIG_REPO`.

## CLI Tools

| Command | Description |
|---------|-------------|
| `ilspycmd` | .NET decompiler CLI |
| `upextract` | `.unitypackage` extractor |
| `ntn` | Notion CLI (`ntn --help`) |

Also preinstalled: `aws`, `fd`, `ffmpeg`, `firebase`, `gcloud`, `gh`, `hyperfine`, `jq`, `just`, `magick`, `mlr`, `optipng`, `ouch`, `parallel`, `pngquant`, `rg`, `sd`, `tofu`, `yq`.
