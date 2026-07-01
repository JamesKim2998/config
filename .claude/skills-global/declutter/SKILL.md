---
name: declutter
description: Clean up and harden an existing area without changing behavior — dead/legacy code, dupes, bloat, weak types, misplaced or giant files, stale TODOs. Not overhaul (research-driven redesign of a scattered subsystem) or simplify (quick pass on just-written code).
---

# Declutter

Make an existing area **clean and robust** without changing external behavior. Prove every removal dead; keep every move's references intact.

`~/.claude/CLAUDE.md` (Code, Authoring, Documentation Policy) and the project `CLAUDE.md` **govern every edit** — re-read if not in context; project policy wins on conflict.

## Scope

`$ARGUMENTS` is the target; **if empty, default to recent work** (`git diff HEAD`, untracked files, this session's commits). Stay within existing contracts and local seams. Hand to `overhaul` when the fix needs a new design, changes a public API, or touches out-of-repo callers — if the target proves to need that mid-run, stop and recommend it. Respect any worktree/session coordination first.

## Phase 1 — Audit

Spawn an `Explore` agent per category below in a single message; each returns hits as `file:line + action` with proof. Synthesize into one ranked, deduped list yourself. Shaky proof → flag *needs confirmation*, don't act on suspicion.

1. **Dead & legacy** — unreferenced symbols/files, commented-out blocks, obsolete flags, dead guards, migration leftovers, and comments/docs narrating superseded behavior ("used to…", "changed in…", "previously…") that no longer describe current code. Capture proof of death.
2. **Duplication** — logic that should collapse to one definition or an existing utility (not coincidental similarity).
3. **Bloat & over-engineering** — premature abstractions, single-consumer indirection, unused params/options/config, speculative generality, comments restating code, docs duplicating source.
4. **Complexity & weak types** — nesting wanting early returns; swallowed errors that should surface; raw primitives for keys/IDs that should be strong types (per global **Code**).
5. **Structure** — code/docs in the wrong place per project layout/doc index; giant files to split along a natural seam (responsibility/topic, not line count).
6. **TODOs & notes** — `TODO.md` items already done or stale; scratch spec/design notes load-bearing enough to graduate into a real doc (registered in the index, scratch copy replaced by a link).

## Phase 2 — Apply

Apply directly — no approval gate; Phase 3 reviews the result. **Every edit obeys these checks:**

- Read the target before removing. Confirm dead against dynamic/reflection/API/persisted refs (zero static callers ≠ dead); never delete a file you haven't opened or a kind the audit didn't model (configs, fixtures, generated sources, assets).
- Prune a TODO only if code unambiguously proves it done — never future or cross-repo items.
- Moving/splitting updates every import, reference, wiki-link, and build path in the same step.
- A type change crossing a serialization/persistence boundary (save data, caches, DTOs, asset/string IDs) → flag *needs confirmation*.
- Without tests/typecheck to back "behavior preserved," restrict to provably-safe edits (dead removal, doc/comment slimming). Skip anything *needs confirmation*.

Partition into units with **disjoint file sets**, then spawn one apply agent per unit in a single message — parallel agents never share a file. Each carries out its edits behavior-unchanged (killing each dead item's doc with it, slimming surviving docs to domain + why — link, don't repeat; keep breadcrumbs), runs typecheck/tests/lint on its scope, and undoes its own red steps with Edit — never `git stash`/`checkout`/`reset` (git state is the user's). Run cross-cutting edits — cross-file dedup, type changes rippling across call sites, moves/splits — as a single serial step to avoid collisions.

## Phase 3 — Review

Spawn review over the resulting diff in a single message — `project-code-review` + `project-doc-review` if the project ships them, else parallel `Explore` agents on the same checks: behavior preserved, nothing live cut, references resolve, needed context not dropped. If review finds behavior changed or something live cut, revert that group and re-verify before continuing. Apply confirmed findings.

## Phase 4 — Report

Summarize by category with what was kept and why. Log deferred/*needs confirmation* items to `TODO.md`.
