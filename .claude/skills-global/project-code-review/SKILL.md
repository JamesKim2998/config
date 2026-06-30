---
name: project-code-review
description: Reviews pending code for style, bugs, and reuse. Use proactively after writing or modifying code.
---

Review recently changed code against project conventions. Default scope: current pending work — `git diff HEAD`, untracked files, session commits. Override with explicit refs or paths.

## Read First

- `~/.claude/CLAUDE.md` — global Code (error handling, control flow, strong types) and Authoring (breadcrumbs, file headers) rules.
- Project `CLAUDE.md` and the dev/style/testing guides it links.

## Explore First

Read each touched file in full (not just the diff); trace callers, callees, tests, related utilities.

## Review

Bugs first, then standards, then style. For each change, ask:

- **Broken?** Logic errors, unhandled null/undefined, boundary cases, swallowed errors.
- **Missing?** Required tests, edge-case and boundary handling.
- **Reinvented?** A canonical home already exists (a pre-existing utility, or one this change adds) — route every hand-rolled copy to it instead of leaving duplicates.
- **Extractable?** No shared home exists yet, but logic is generic or genuinely repeated — lift it into core/utility/common so it has one home. Real repetition only; don't abstract speculatively (see Bloated?).
- **Bloated?** Over-engineering, premature abstraction, dead code, redundant guards, unused imports.
- **Misleading?** Wrong/weak types, names that don't match behavior, comments restating or contradicting code.
- **Off-convention?** Violations of the global or project guides.

## Docs Check

If the change adds/removes/renames a feature/CLI/workflow, flag the now-inaccurate doc section — don't draft fixes. Hand deeper evaluation to `project-doc-review`.

## Verify

Run the project's documented checks (lint/typecheck/test).

## Second Eye (optional)

For high-stakes work, spawn a parallel subagent on the same scope; compare findings before reporting.
