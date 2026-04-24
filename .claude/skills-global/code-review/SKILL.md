---
name: code-review
description: Reviews pending code for style, bugs, and reuse. Use proactively after writing or modifying code.
---

Review recently changed code against project conventions. Default scope: current pending work — `git diff HEAD`, untracked files, plus session commits. Override with explicit refs or paths.

## Read First

- `~/.claude/CLAUDE.md` — global Code (error handling, control flow) and Authoring (breadcrumbs, file headers) rules.
- Project `CLAUDE.md` — structure, conventions, doc index.
- Dev/style and testing guides it links to (e.g. `development-guide.md`, `testing-guide.md`, `foundation.md`).

## Explore First

Trace callers, callees, tests, and related utilities — shallow review misses real issues.

## Priority

Bugs > standards > style.

## Focus

- **Bugs** — logic errors, unhandled null/undefined, boundary cases.
- **Style conformance** — violations of rules in the project guides.
- **Reuse** — duplicated logic that should use utilities already in the project.

## Rubric

- **Essentials missing?** Tests, edge cases, error handling at boundaries.
- **Bloated?** Over-engineering, premature abstraction, dead code.
- **Trivial?** Comments restating code, redundant guards, unused imports.
- **Misleading?** Wrong types, names that don't match behavior, stale comments.

## Docs Check

If the change adds/removes/renames a feature/CLI/workflow, flag any related doc that's now inaccurate. Point at the section needing edits — don't draft fixes inline. For deeper doc evaluation, defer to `doc-review`.

## Test Coverage

Check tests exist where the project's testing guide requires them.

## Verify

Run the project's standard checks (lint/typecheck/test) as documented in the project guides.

## Second Eye (optional)

For high-stakes work, spawn a parallel subagent on the same scope — clean context catches what you miss. Compare findings before reporting.
