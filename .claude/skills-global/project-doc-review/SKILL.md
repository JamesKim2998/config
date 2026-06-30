---
name: project-doc-review
description: Sync docs with code, evaluate doc quality, and consolidate redundancies. Use when docs drift, cross-references break, or before doc-heavy reviews.
---

Review docs against the Documentation Policy in `~/.claude/CLAUDE.md` and project `CLAUDE.md` (re-read if not in context; project wins on conflict). This skill owns doc quality, structure, and code-sync; leave code correctness to `project-code-review`.

Default scope: doc files in the current pending work — `git diff HEAD`, untracked docs, session commits. Override with explicit refs or paths.

## Explore First

Read each touched doc **in full** (not just the diff), the code it describes, and the docs it links to or from — shallow review misses contradictions and drift.

## Checklist

- **Code-doc sync** — APIs, paths, examples, CLI flags match current code; no enumerations of source-discoverable items.
- **Reference-don't-repeat** — the same fact duplicated across docs; pick one canonical home, link the rest. (Doc restating code/source is Right medium's call.)
- **Right medium** — each fact lives as code (self-evident), a comment (local "why"), or a doc (domain/cross-cutting) — pick one. Flag doc prose only needed at the code, and comment-worthy rationale buried in a doc. (Comments vs code are `project-code-review`'s call.)
- **Progressive disclosure** — content in the right layer (root `CLAUDE.md` minimal → `docs/…` → package-local); flag bloat, over-explanation, and content adding nothing over common sense.
- **Crosslinks** — every `[[doc.md#anchor]]` resolves to the correct kebab-case slug, reciprocal links present; same-repo wiki-links, cross-repo backtick+suffix; filename-only.
- **Index & headers** — new/moved docs registered in the index (no orphans); each opens with `> **Related:**`.
- **Information loss** — diffs drop no essential domain knowledge or breadcrumb; whole docs aren't missing guidance a reader needs.
- **Full policy coverage** — every Documentation Policy principle, including any not above (e.g. domain over implementation, Mermaid not ASCII).

## Verify

Run the project's link/orphan checks if any (e.g. pre-commit hooks); otherwise resolve wiki-links and anchors by hand.

## Second Eye (optional)

For high-stakes work, spawn a parallel subagent on the same scope; compare findings before reporting.
