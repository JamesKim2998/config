---
name: wrap-up
description: General session wrap-up — run code/doc reviews if needed, capture breadcrumbs and lost context, sync TODOs. Use at end of task, before a break, or before /clear.
---

`~/.claude/CLAUDE.md` and the repo's `CLAUDE.md` govern every step below. Re-read them if not in context.

1. **Change snapshot** — Capture everything the session touched:
   - `git status --short` — lists tracked modifications and untracked files.
   - `git diff HEAD` — all tracked changes (staged + unstaged combined).
   - Read untracked files in full — they don't appear in the diff.
   - If commits landed this session, include `git log <branch-point>..HEAD` and `git diff <branch-point>..HEAD` (merge-base with the default branch).
   - Note non-repo side effects too (files written outside the repo, settings changed, external state).
2. **Delegated reviews** — If `code-review` and `doc-review` haven't already run on the current pending changes, spawn them in parallel via agents. Hand them the step-1 scope (refs for session commits + explicit paths for untracked files) so they cover the same ground.
3. **Audit** — Two sources:
   - **From this chat** (stays in the main session — a fresh agent has no transcript): decisions, conventions, or rejected alternatives raised in conversation that belong in docs but didn't land.
   - **From the change set** (agent on the step-1 scope):
     - **Breadcrumb gaps** — code sites missing the pointers called for by Authoring rules.
     - **Deferred items** — follow-ups, dead-ends, or issues noticed mid-task that belong in `TODO.md`.
4. **Apply updates** — Walk all findings:
   - Resolve (or defer with reasoning) the reviews' and audit's findings.
   - Add flagged breadcrumbs inline.
   - Append deferred items to `TODO.md` with enough context to resume cold.
5. **Report** — Summarize updates and queued items. If asked, append a paste-ready handoff prompt for the next session.
