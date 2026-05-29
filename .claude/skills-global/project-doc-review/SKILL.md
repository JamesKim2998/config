---
name: project-doc-review
description: Sync docs with code, evaluate doc quality, and consolidate redundancies. Use when docs drift, cross-references break, or before doc-heavy reviews.
---

Review docs against the Documentation Policy in `~/.claude/CLAUDE.md` and project `CLAUDE.md` (re-read if not in context; project wins on conflict). This skill owns doc quality, structure, and code-sync; leave code correctness to `project-code-review`.

Default scope: doc files in the current pending work — `git diff HEAD`, untracked docs, session commits. Override with explicit refs or paths.

## Explore First

Read each touched doc **in full** (not just the diff), the code it describes, and the docs it links to or is linked from — shallow review misses contradictions and drift.

## Checklist

- **Code-doc sync** — APIs, paths, examples, CLI flags match current code; no enumerations of source-discoverable items (they go stale).
- **Reference-don't-repeat** — content duplicated across docs or restating source/policy; pick one canonical home, replace the rest with links.
- **Progressive disclosure** — content in the right layer (root `CLAUDE.md` minimal → `docs/…` → package-local); flag bloat, over-explanation, and content adding nothing over common sense.
- **Crosslinks** — every `[[doc.md#anchor]]` resolves, anchors are the correct kebab-case heading slug, reciprocal links present; same-repo uses wiki-links, cross-repo uses backtick+suffix; filename-only per convention.
- **Doc index & headers** — new/moved docs registered in the index (no orphans); each doc opens with `> **Related:**`.
- **Information loss** — for diffs, verify no essential domain knowledge or breadcrumb was dropped; for whole docs, flag guidance a reader genuinely needs but that's absent.
- **Full policy coverage** — every Documentation Policy principle, including any not broken out above (e.g. domain over implementation, Mermaid not ASCII).

## Verify

Run the project's link/orphan checks if it has them (e.g. pre-commit hooks); otherwise resolve wiki-links and anchors by hand.

## Second Eye (optional)

For high-stakes work, spawn a parallel subagent on the same scope and compare findings before reporting.
