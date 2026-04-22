---
name: doc-review
description: Sync docs with code, evaluate doc quality, and consolidate redundancies. Use when docs drift, cross-references break, or before doc-heavy reviews.
---

Review docs against the Documentation Policy in `~/.claude/CLAUDE.md` and any project-specific additions in the project `CLAUDE.md`. Default scope: `git diff HEAD` (docs only). Accepts a commit ref (e.g. `HEAD~3..HEAD`) or file paths as an override.

## Explore First

Read the code each doc describes and the linked/linking docs — shallow review misses real issues. Read each touched file **in full**, not just the diff.

## Focus

- **Policy compliance** — each principle in the Documentation Policy.
- **Structure** — progressive disclosure; flag bloated sections.
- **Location** — content lives in the right layer (root `CLAUDE.md` vs. `docs/…` vs. package-local docs).
- **Redundancy** — same content in multiple places; pick one canonical spot and replace duplicates with links.
- **Cross-references** — missing reciprocal links; contradictions between docs or with code.
- **Code-doc sync** — APIs, paths, examples, CLI flags that no longer match the code.
- **Information loss** — for diffs, verify no essential domain knowledge was dropped.

## Rubric

- **Essentials missing?** Any rule, section, or guidance a reader would genuinely need.
- **Bloated?** Phrasing or bullets that could be tighter.
- **Trivial?** Content that adds no value over common sense or other docs.
- **Misleading?** Stale references, wrong section names, or statements that contradict the code.

## Verify

Run the project's pre-commit hooks (e.g. `lefthook run pre-commit`) so markdown link/orphan checks pass — broken targets/anchors are typically auto-caught there.

## Second Eye (optional)

For high-stakes work, spawn a parallel subagent on the same scope — clean context catches what you miss. Compare findings before reporting.
