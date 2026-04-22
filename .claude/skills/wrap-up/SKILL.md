---
name: wrap-up
description: Final doc and TODO sync before /clear. Preserves session knowledge before the context window is discarded.
---

Before anything else, read both `CLAUDE.md` files in full if not already in context:
- Global: `~/.claude/CLAUDE.md` — Documentation Policy, Workflow (Git, TODO), Authoring rules.
- Project: `<repo>/CLAUDE.md` — project-specific doc layout, doc index, conventions.

Internalize them; they govern every step below.

1. **Diff review** — `git status`, `git diff`, `git diff --cached`. Note decisions, findings, and dead-ends not captured in code.
2. **Sync docs** — Update `CLAUDE.md` and the project doc tree entries touched by the session to match new behavior. Strip facts that moved into code; link rather than duplicate.
3. **Log `TODO.md`** — Append deferred items with enough context to resume cold: incomplete work, follow-ups, issues noticed mid-task.
4. **Report** — Summarize updates and queued items. Flag anything to commit before `/clear` — do not auto-commit.
