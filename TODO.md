# TODO

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
