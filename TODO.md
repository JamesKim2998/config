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

Deferred from the `o`-on-folder fix session ([[yazi.md#testing]]).

- **Move env-injection into `TmuxRunner.startYazi()`** (`diagnostics/lib.ts:229`).
  `yazi-folder-open.test.ts` reimplements `sendRaw`/`kill`/`cleanup` inline
  because it needs a `sh -c 'EDITOR=… PATH=… exec yazi'` wrapper — tmux's
  `-e KEY=VAL` flag is shadowed by the user's `update-environment`. Suggested
  signature: `startYazi(opts?: { env?: Record<string,string>; startupDelay?: number })`.
  Add a line comment with the rationale per ~/.claude/CLAUDE.md "Implementation Rationale".
  Once landed, refactor `yazi-folder-open.test.ts` to use `TmuxRunner`.

- **Replace fixed `Bun.sleep(1000)` after `o` with marker-file polling**
  (`diagnostics/yazi-folder-open.test.ts`:78). Currently relies on the child
  opener writing the marker within 1s — flaky on slow CI. Poll with a 3s deadline.

- **Position cursor explicitly via `ya emit reveal <path>`** instead of
  `gg` + `/<name>` + `Enter` (`diagnostics/yazi-folder-open.test.ts` `pressOOn`).
  Filter-then-Enter selects the wrong row if a future fixture creates a name
  prefix collision (e.g. adding `subdir2` would silently break the `subdir` test).
