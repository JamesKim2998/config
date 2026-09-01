---
name: project-doc-review
description: Sync docs with code, evaluate doc quality, and consolidate redundancies. Use when docs drift, cross-references break, or before doc-heavy reviews.
---

Review docs against the **Authoring** and **Docs** rules in `~/.claude/CLAUDE.md` and project `CLAUDE.md` — re-read if not in context; project wins on conflict. The checklist below is a shortcut through them, not a substitute. This skill owns doc quality, structure, and code-sync; code and comments are `project-code-review`'s call.

## Scope

Doc files in the current pending work — `git diff HEAD`, untracked docs, session commits. Override with explicit refs or paths. Read each touched doc **in full**, the code it describes, and the docs it links to or from: contradictions hide outside the diff, and a misplaced section is only visible next to its rightful home.

## Checklist

- **Code-doc sync** — APIs, paths, examples, CLI flags match current code; no enumerations of source-discoverable items.
- **Right medium** — each fact is code (self-evident), a comment (local "why"), or a doc (domain/cross-cutting). Flag doc prose only needed at the code, and comment-worthy rationale buried in a doc.
- **One source** — the same fact stated twice; name the canonical home, link the rest.
- **Right home** — one concern per doc, every section in the doc owning its topic, at the right layer (root `CLAUDE.md` minimal → `docs/…` → package-local), folder, and filename. Propose the concrete move: section → doc, doc → path, split along responsibility, merge a scattered topic. No owner? A new doc, or deletion if the content doesn't earn one.
- **Slimmer** — every reviewed doc ends shorter: cut filler, history, over-explanation, and restating. Delete rather than reword.
- **Links & index** — `[[doc.md#anchor]]` resolves to the right kebab-case slug, reciprocal links present, every doc registered in the index and opening with `> **Related:**`; same-repo wiki-links, cross-repo backtick+suffix, filename-only. Moves carry their inbound links and index entries.
- **No loss** — neither the diff nor your own cuts and moves drop domain knowledge or a breadcrumb a reader needs.

## Before Reporting

Run the project's link/orphan checks if any (e.g. pre-commit hooks); otherwise resolve wiki-links and anchors by hand. For high-stakes work, spawn a parallel subagent on the same scope and compare findings.
