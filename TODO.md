# TODO

## Yazi soft filter — visual reorder (blocked on upstream)

`plugins/soft-filter.yazi` dims non-matches and offers `n`/`N` to walk
between matches, but matches don't visually bubble to the top of the list.

**Why it's deferred.** Plugin-driven reorder needs upstream changes:
`SortBy` is a closed Rust enum dispatched in a `match` block
(`sorting.rs:10`, `sorter.rs:36` (sxyazi/yazi)); the Lua `Files` userdata
is read-only — no `__newindex`/`sort`/`swap` (`files.rs:32`); the `sort`
action only deserialises `SortBy` enum values (`sort.rs:8`).

A render-only reorder via `Current:redraw` is technically doable but
would force every nav keybind (`j`/`k`/`gg`/`G`/`arrow`) to be re-mapped
to translate between visual and data indices — too much surface for too
little gain over dim + `n`/`N`.

**Action item.** File a feature request on sxyazi/yazi for a
plugin-pluggable comparator if/when the current behaviour proves
insufficient.

## Kitty — random framebuffer glitch on `cmd+return` (vsplit)

Intermittent (~1/3) horizontal-stripe corruption of the entire OS window when
splitting via `cmd+return`. Looks like GPU framebuffer corruption, not a
content/layout bug. Env: macOS 26.3.1, M3 Pro, Retina, kitty 0.46.2.

**Status:** mitigation applied, **awaiting ~1 week of normal-use visual inspection**
to confirm. User confirmed first session looks OK but glitch is intermittent
so single observation insufficient.

- **Mitigation applied:** `window_border_width 2pt` → `2px`
  (`kitty/kitty.conf:15`). Theory: at 2x retina, 2pt ≈ 2.67px → fractional
  border re-rasterizes for every window on each layout change (since
  `draw_minimal_borders no`), driver-pressure race. Integer-px removes the
  rounding step.
- **If it persists:** revert and try `inactive_text_alpha 1.0` next (drops
  the per-window alpha-blend redraw on relayout). Then try
  `draw_minimal_borders yes`.
- **Upstream:** file at github.com/kovidgoyal/kitty with
  `kitty --debug-rendering` log + recording + kitty.conf. Closest existing:
  [#8012](https://github.com/kovidgoyal/kitty/issues/8012) (random,
  undiagnosed, fixed by resizing — same fingerprint).

## Kitty — equalize-on-split fires only sometimes

Discovered while testing the framebuffer-glitch fix above. After `cmd+return`
the new pane often kept a near-zero width — equalize ran some launches but
not others. Attempts so far have **not** resolved it; user reports "still same"
after each iteration. **Awaiting visual inspection of latest debug build.**

- **Original setup:** `cmd+return → launch --location=vsplit`, with
  `equalize.py` watcher only handling `on_close`. Splits never auto-equalized.
- **Attempt 1 (rejected):** `combine : launch ... : kitten equalize.py` on
  every split keybinding. Symptom persisted intermittently — kittens are
  spawned subprocesses talking back via RPC, racing the layout update.
- **Attempt 2 (rejected):** moved equalize into a watcher `on_resize` hook
  guarded by `old_geometry.left/top/right/bottom == 0` (in-process, no RPC
  race). Still intermittent — pixel coords aren't the documented "first
  creation" signal.
- **Attempt 3 (current):** swapped the guard to `old_geometry.xnum/ynum == 0`
  per kitty docs (`kitty/equalize.py:34`). User reports "still same" — but
  watcher Python modules are **cached at startup**; `ctrl+shift+f5` does not
  re-import them. Unclear whether attempt 3 was tested with a full
  cmd+Q + relaunch.
- **Next step:** if still intermittent after a full kitty cmd+Q + relaunch,
  re-add temporary logging to `/tmp/kitty-equalize.log` in `on_resize` to
  inspect the `data` dict and confirm whether the watcher fires on launch.
  Reference: [kitty docs — Watching launched windows](https://sw.kovidgoyal.net/kitty/launch/).

## Yazi diagnostics — harness improvements

Deferred follow-ups from the test-infra overhaul ([[yazi.md#testing]]).

- **Position cursor explicitly via `ya emit reveal <path>`** instead of
  `gg` + `/<name>` + `Enter` (`diagnostics/yazi-folder-open.test.ts` `pressOOn`).
  Filter-then-Enter selects the wrong row if a future fixture creates a name
  prefix collision (e.g. adding `subdir2` would silently break the `subdir` test).

- **Structured env quoting in `TmuxStartOpts`** (`diagnostics/lib.ts`).
  `env` values are inserted raw into `sh -c` so `yazi-folder-open.test.ts`
  can write `PATH: "${BIN_DIR}:$PATH"` and have `$PATH` expand. Callers
  wanting whitespace or `$`/quotes in a value (e.g. `EDITOR='code -w'`)
  currently break silently. When the second caller appears, split into
  `env` (printf %q-escaped) vs `envRaw` (literal), or add an opt-in
  `expand: true` flag.

## Yazi `git-status.yazi` — submodule worktrees show submodule name

`yazi/plugins/git-status.yazi/main.lua` derives the repo label from
`git rev-parse --git-common-dir`, which inside a submodule resolves to
`<super>/.git/modules/<name>` — so the status bar reads the submodule
slug, not the super-repo name. Strip up to `.git/modules/<name>` for that
case if it actually shows up in normal navigation. Deferred — none of our
tracked submodules are big enough to navigate inside in yazi.

## Yazi `worktree-jump` — fzf exit-1 toast wording

`worktree-jump.yazi/main.lua` notifies "no worktree selected" on `fzf` exit
code 1. With the new pre-flight count, exit 1 is now mostly unreachable
(zero/one-candidate cases bail earlier). If it ever fires in practice it
means the awk pipeline produced zero rows from a multi-worktree porcelain —
which would be a real bug. Replace the soft toast with `fail("…")` once
that's confirmed to be the only remaining trigger.

## Claude busy indicator — multi-session-in-one-tab edge case

`kitty/claude-busy.py` mutates *tab* title (the only signal channel for
manually-renamed tabs, since `tab_title_template` is bypassed when
`title_overridden: True`). If two Claude Code sessions share one kitty tab,
a `Stop` from session A strips the icon while session B is still busy —
the indicator no longer reflects "any Claude in this tab is working."

**Possible fix.** Reference-count via a tab-level user-var (`busy_count`),
increment on `set`, decrement on `clear`, only mutate title when count
crosses 0↔1. Defer until the case actually hits in normal use.

## Tailscale CGNAT daemon — hardening (deferred from code review)

`tailscale/cgnat-route.sh` works on the home/office LAN but has latent gaps:

- **`install()` bootout→bootstrap race.** `launchctl bootout` is async; the
  immediate `bootstrap` can fail (`Bootstrap failed: 5`) on *reinstall*, which
  under `setup.sh`'s `set -e` aborts the whole run. First install is fine
  (bootout is a no-op). Fix: poll until the old label is gone, or `bootstrap`
  then `kickstart -k`.
- **`ts_if` awk under-constrained.** Matches any `inet 100.` on any interface,
  not gated to a `utun` section nor the `100.64/10` range; on a CGNAT network
  that puts 100.64.x directly on en0/Wi-Fi it silently no-ops or mis-targets.
- **Misleading log.** `logger "repointed"` fires even when `route add` failed
  (swallowed by `|| true`); log only on success.

Not reachable on the private 192.168 LAN, so deferred.
