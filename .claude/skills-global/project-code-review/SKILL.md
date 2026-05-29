---
name: project-code-review
description: Reviews pending code for style, bugs, and reuse. Use proactively after writing or modifying code.
---

Review recently changed code against project conventions. Default scope: current pending work — `git diff HEAD`, untracked files, plus session commits. Override with explicit refs or paths.

## Read First

- `~/.claude/CLAUDE.md` — global Code (error handling, control flow, strong types) and Authoring (breadcrumbs, file headers) rules.
- Project `CLAUDE.md` — structure, conventions, doc index.
- Dev/style and testing guides it links to (e.g. `development-guide.md`, `testing-guide.md`).

## Explore First

Read each touched file in full — not just the diff — and trace callers, callees, tests, and related utilities.

## Review

Bugs first, then standards, then style. For each change, ask:

- **Broken?** Logic errors, unhandled null/undefined, boundary cases, errors swallowed instead of surfaced.
- **Missing?** Tests where the testing guide requires them, edge-case and boundary handling.
- **Reinvented?** Duplicated logic that should use an existing project utility.
- **Bloated?** Over-engineering, premature abstraction, dead code, redundant guards, unused imports.
- **Misleading?** Wrong/weak types, names that don't match behavior, comments restating or contradicting the code.
- **Off-convention?** Violations of rules in the global or project guides.

## Docs Check

If the change adds/removes/renames a feature/CLI/workflow, flag the now-inaccurate doc section — don't draft fixes. Hand deeper doc evaluation to `project-doc-review`.

## Verify

Run the project's documented checks (lint/typecheck/test).

## Second Eye (optional)

For high-stakes work, spawn a parallel subagent on the same scope — clean context catches what you miss. Compare findings before reporting.
