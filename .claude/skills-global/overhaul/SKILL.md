---
description: Deep research + codebase audit + clean redesign + refactor of a messy, scattered subsystem
---

# Overhaul

End-picture first; migration cost does not matter *inside* the subsystem, but external callers must be updated atomically per checkpoint.

## Project frame

Re-read the project's `CLAUDE.md` (root + nested) for genre, scale, stack, and architectural constraints before starting. Reviews below must filter recommendations against that frame — reject reference designs scaled for a different problem class unless the *concrete tradeoff* applies. **Borrow ideas, not architecture.**

## Input

`$ARGUMENTS` — the subsystem to overhaul. If empty or too broad to fit one overhaul, stop and ask the user to narrow scope.

If the project uses worktrees or any session-coordination mechanism (per its `CLAUDE.md`), check for an in-flight session already touching this subsystem before starting.

## Phase 1 — Parallel research

Spawn these in a **single message**, all foreground.

1. **External research** (`general-purpose`, may use `WebSearch` / `WebFetch`):
   - Canonical architectures for `$ARGUMENTS` in projects of comparable genre/scale (use the host `CLAUDE.md` to pick comparables).
   - Reference implementations worth studying — prefer codebases of similar size over engines/frameworks.
   - Common pitfalls; flag overengineering tells (heavyweight patterns where direct calls suffice, registry/plugin systems with one consumer, etc.).
   - Report: bullet list of patterns with one-line tradeoffs + links, each tagged "fits / scaled-down idea / skip — wrong scale."

2. **Codebase audit** (`Explore`, `very thorough`):
   - Every file/module/function/call site touching `$ARGUMENTS`.
   - Current responsibilities, duplications, leaky abstractions.
   - **External callers** that need atomic updates during refactor; flag any out-of-repo callers as a separate coordination problem.
   - **Pinned invariants** — existing tests, type contracts, persisted state (save files, on-disk caches, schemas) that outlive code.
   - Report: file:line inventory grouped by concern; worst smells; explicit caller list; invariant list.

3. **Use-case & integration** (`Explore`, `medium`):
   - How is `$ARGUMENTS` consumed? Which systems, tests, docs?
   - What invariants do callers assume vs. what they actually need?
   - Report: ranked use cases + the minimum surface each needs.

Wait for all three. **Synthesize yourself — do not delegate synthesis.** Summarize back to the user (≤10 bullets): what exists, what's broken, what literature recommends. If true blast radius is too large, re-fire scope check. If research is inconclusive or the audit shows the subsystem isn't actually messy, stop and report — don't manufacture an overhaul.

## Phase 2 — Design

Draft the clean end-state. Ignore the current system and migration cost. Cover:

- Module boundaries, types, ownership.
- Data flow and lifecycle.
- Public API — only what Phase 1 use cases need.
- Where it lives in the tree; integration with the project's DI / composition pattern.
- **Persisted-state migration plan** if Phase 1 surfaced any. The "no shims, no dual paths" rule applies to code, not to data that outlives code.
- Open questions / deferred decisions.

Land the design as a draft doc per the project's documentation conventions; Phase 4 finalizes it.

Then **review in parallel** (single message):

1. `Plan` — architecture sanity-check, missed edge cases, alternatives where the design over- or under-reaches.
2. Adversarial `general-purpose` — *simplification only*. What can be deleted? Smallest version that still covers Phase 1?
3. `Explore` — verify proposed integration points match how the rest of the codebase is structured today.

Synthesize. If a reviewer flags a structural issue, redesign and re-review. If reviewers fundamentally disagree, surface to the user; don't average. Present final design and **ask user approval before refactoring**.

## Phase 3 — Refactor

Only after user approval.

- Confirm the working environment matches the project's expectation for risky multi-commit work (worktree, branch, etc., per its `CLAUDE.md`).
- Break the refactor into checkpoints; mark done as you go.
- Each checkpoint updates external callers atomically — no broken builds between commits.
- Delete old code as you replace it — no compatibility shims, no dual paths. (Persisted-state migration follows the Phase 2 plan.)
- When code is deleted, its doc dies in the same commit.
- Run typecheck / tests / runtime smoke check between checkpoints.
- Lightweight code review per checkpoint if available; cheap-to-fix issues compound.
- If the refactor wedges (typecheck red across multiple checkpoints, design assumption broken), revert to last green and return to Phase 2.

## Phase 4 — Subsystem doc

Rewrite the Phase 2 draft against what shipped. Patch nothing — rewrite stale sections.

- Register the doc in the project's top-level doc index if it isn't already.
- **Carry forward Phase 1 breadcrumbs** — vendor docs, blog posts, RFCs, reference implementations — as inline links where they justify a local decision, plus a `## References` section at the bottom. Future readers must be able to retrace *why* the design landed here.
- Distill Phase 1 into the doc body. Suggested sections (merge/rename to fit):
  - `## Background` / `## Prior art` — patterns considered, which won, the sealing tradeoff. One or two sentences each; link out.
  - `## Use cases` — ranked real consumers with minimum surface needed. Anchors the API.
  - `## Pitfalls` — common traps from the literature *and* smells from the audit, paired with how the new design avoids them. Future overhaulers should not have to re-discover these.
  - `## Non-goals` — what the subsystem deliberately does not do.

## Phase 5 — Review pass

After refactor + doc land and smoke checks are green, run two reviews back-to-back. If the project ships review skills (e.g. `/code-review`, `/doc-review`), invoke them via `Skill`; otherwise do an inline pass covering the same ground.

1. **Code review** — full pass over the cumulative refactor (per-checkpoint passes only saw slices). If structural issues surface, return to Phase 3 with a new checkpoint; don't patch in Phase 5.
2. **Doc review** — propagate outward: caller docs whose invariants shifted, top-level architecture index, deleted-code doc removal. Spot-check the Phase 4 subsystem doc here.

Apply fixes, commit at a checkpoint, declare done.
