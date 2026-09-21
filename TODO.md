# TODO

## Yazi soft filter — matches don't move to top

Blocked upstream: `SortBy` is a closed enum and Lua `Files` is read-only (sxyazi/yazi). A render-only reorder would remap every nav key — dim + `n`/`N` is enough. If not, request a pluggable comparator upstream.

## Kitty — framebuffer glitch on vsplit

~1/3 of `cmd+return` splits stripe-corrupt the whole window (macOS 26.3.1, M3 Pro, kitty 0.46.2). Watching integer-px `window_border_width` (fractional pt re-rasterizes on relayout). If it persists: revert → `inactive_text_alpha 1.0` → `draw_minimal_borders yes` → file upstream with a `kitty --debug-rendering` log (cf. [#8012](https://github.com/kovidgoyal/kitty/issues/8012)).

## Kitty — equalize-on-split intermittent

`on_resize` in `equalize.py` is untested after a full relaunch (watchers don't reload). If still intermittent, log its `data` to confirm it fires.

## Yazi diagnostics

- `pressOOn` (`yazi-folder-open.test.ts`) selects by name filter, breaking on prefix collisions — use `ya emit reveal <path>`.
- `TmuxStartOpts.env` (`lib.ts`) goes unescaped into `sh -c`; split escaped vs raw once a value needs quoting.

## Yazi `git-status.yazi` — submodule label

Inside a submodule `--git-common-dir` yields `.git/modules/<name>`; strip it if browsing submodules becomes common.

## Yazi `worktree-jump.yazi` — fzf exit 1

The pre-flight count leaves exit 1 meaning a pipeline bug; swap the toast for `fail()` once confirmed.

## Claude busy indicator — shared tab

With two sessions in one tab, one `Stop` clears the other's icon. Ref-count via a tab user-var if it hits.

## Tailscale `cgnat-route.sh` — hardening

Unreachable on the 192.168 LAN:

- Reinstall: async `bootout` races `bootstrap`, aborting `setup.sh`; poll or `kickstart -k`.
- `ts_if` matches any `inet 100.`; gate to `utun` in `100.64/10`.
- `logger "repointed"` fires on a failed `route add`.

## `notify-done.sh` — declined for leanness

- No fallback when `alerter` is missing.
- Concurrent Stops stack banners.
- [ ] The other laptop's `~/.zshenv.local` still exports the `MEOW_*` paths boxcat-devenv generates.
      They agree, so nothing breaks; delete them once it has run `just bootstrap` there.
## `diagnostics/` does not typecheck

`boxcat-devenv typecheck` runs `bun run typecheck` in `diagnostics/` and it fails: `cursor-shape.ts` imports
`MACMINI_DEST` and `MACMINI_SSH_KEY` that `lib.ts` no longer exports, and `nvim-startup.ts`, `yazi-worktree-jump.test.ts`
and `macmini-latency.ts` index into arrays without a guard (29 errors). Unrelated to any package; a host-wide compile
sweep is red until it is fixed or the package says it is not compiled (`.boxcat.env.json` `typecheck: { none }`).
