# Yazi Config

File manager with plugins, custom keymaps, and previewers.

> **Related:** [[nvim-plugin-testing.md]] (shared test harness)

## Custom Keymaps

| Key | Action |
|-----|--------|
| `q` | Close tab (quit if last) |
| `Tab` / `S-Tab` | Next/prev tab |
| `i` | File info (spot) |
| `/` | Soft filter (dim non-matches; ESC clears, Enter keeps) |
| `n` / `N` | Jump to next / prev soft-filter match |
| `Esc` (in any input prompt) | Cancel/close (overrides yazi's default vi-mode switch) |
| `Esc` (manager) | Clear soft filter, then default escape |
| `S` | Ripgrep search (case-insensitive) |
| `Space` | Toggle selection (no auto-move) |
| `l` | Smart enter (dir → cd, file → open) |
| `o` | Open with default application |
| `O` | Open menu (pick edit / open / reveal) |
| `R` | Reveal in Finder (macOS) |
| `f` | Jump to char |
| `T` | Toggle preview pane |
| `<C-n>` | Toggle parent pane |
| `gi` | Open lazygit |
| `gr` | Cd to git root |
| `Y` | Copy absolute path |
| `w` | Jump to git worktree (fzf picker over `git worktree list`) — overrides default `tasks:show` |
| `W` | Show task manager (default `w` action, moved here) |

### Open Rules

Default preset has `{ url = "*/", use = [ "edit", "open", "reveal" ] }` for
directories — pressing `o` runs `$EDITOR <folder>`. We prepend a rule with
`open` first so `o` reveals folders (and `.app` bundles) via macOS `open`
instead. See `yazi/yazi.toml`.

## Plugins

| Plugin | Purpose |
|--------|---------|
| fr.yazi | Ripgrep search with fzf |
| bat.yazi | Syntax-highlighted text preview |
| xleak.yazi | Fast Excel preview (uses xleak) |
| langpack.yazi | meow-tower langpack binary preview |
| office.yazi | Office document preview (LibreOffice) |
| ouch.yazi | Archive preview/compression |
| mediainfo.yazi | Media file info/preview |
| git.yazi | Git status in file list |
| mactag.yazi | macOS Finder tags |
| soft-filter.yazi | Local: dim non-matches on `/` (vs. yazi's hide-filter); per-dir scoped |
| worktree-jump.yazi | Local: fzf picker over `git worktree list`, cd to selection |

### xleak.yazi

Fast Excel preview using [xleak](https://github.com/bgreenwell/xleak)
(Rust-based). Falls back to bat for HTML files disguised as `.xls` (common in
Korean bank exports). Install: `cargo install xleak`.

## Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| bat | Syntax highlighting | `brew install bat` |
| xleak | Excel preview | `cargo install xleak` |
| poppler | PDF preview (pdftoppm) | `brew install poppler` |
| ffmpegthumbnailer | Video thumbnails | `brew install ffmpegthumbnailer` |
| exiftool | Image/media metadata | `brew install exiftool` |
| pandoc | Document conversion | `brew install pandoc` |
| libreoffice | Office document conversion | `brew install --cask libreoffice` |
| ouch | Archive handling | `brew install ouch` |
| mediainfo | Media file info | `brew install mediainfo` |

## Testing

E2E tests live in `diagnostics/yazi-*.test.ts` and drive yazi inside a tmux
session via `TmuxRunner` (`diagnostics/lib.ts`). They run against the user's real
`~/.config/yazi/` (no config sandboxing), so the symlink from `setup.sh` must
be in place.

```bash
cd diagnostics
bun test yazi-fr.test.ts            # ripgrep search via fr.yazi
bun test yazi-folder-open.test.ts   # 'o' on dirs/.app uses macOS open
bun test yazi-tps-open.test.ts      # opener menu for .tps files
bun test yazi-soft-filter.test.ts   # soft-filter type-to-jump, n/N, Esc clears
bun run yazi                        # all yazi-*.test.ts
```

### Test pattern: send → waitFor (never sleep)

`TmuxRunner` exposes `start({cmd, cwd, cols, rows, env})`, `sendRaw`,
`sendLiteral`, `capture`, and `waitFor(matcher, opts)`. The discipline is:
after each input, **poll the screen for an anchor** instead of sleeping. The
helper is modeled on fzf's `Tmux#wait` ([test/lib/common.rb][fzf-wait]).

```ts
const tmux = new TmuxRunner("yazi-foo-test");
await tmux.start({ cmd: "yazi", cwd: TEST_DIR });
await tmux.waitFor("apple.txt");           // UI ready
await tmux.sendRaw("/");
await Bun.sleep(100);                      // soft-filter prompt has no visible state
await tmux.sendLiteral("apr");
await tmux.waitFor("󰈲 apr");               // chip ⇒ filter live
await tmux.sendRaw("Enter");
await tmux.waitFor(`${TEST_DIR}/apricot.txt`); // bottom status path ⇒ cursor moved
```

Anchor cheat sheet for our config:

| Anchor | Confirms |
|--------|----------|
| `${TEST_DIR}/<file>` (bottom-right status) | Cursor is hovered on `<file>` |
| `󰈲 <query>` (bottom-left status) | Soft-filter is active with `<query>` |
| `<path>:1:` row (fr.yazi only) | fzf has at least one match |

Pitfall: file/dir names appear in the listing regardless of filter or
cursor state, so a bare `waitFor("apple.txt")` only proves the UI is up —
not that anything moved. To assert state changes, anchor on the **status
bar path** (updates on hover) or the **filter chip** (only present when
active).

`start()` pins `-x 120 -y 40`, `TERM=xterm-256color`, `LANG=en_US.UTF-8`,
and `escape-time 0` — the last makes `<Esc>` dispatch immediately instead of
waiting tmux's default 500ms grace.

[fzf-wait]: https://github.com/junegunn/fzf/blob/master/test/lib/common.rb

### Detecting which opener fired

Yazi spawns the opener as a child process. To tell whether `edit` or `open`
ran without launching a real editor or Finder window, the test:

1. Writes shim scripts at `${TEST_DIR}/bin/{open,fake-editor}` that just
   `touch` a marker file.
2. Launches yazi via `tmux.start({cmd: "yazi", cwd: TEST_DIR, env: {EDITOR,
   PATH: \`${BIN_DIR}:$PATH\`}})`. `env` values are inserted raw into the
   wrapper `sh -c`, so `$PATH` expands.
3. Sends keys, then polls until the marker file appears.

See `diagnostics/yazi-folder-open.test.ts` for the pattern.

## Configuration Notes

### URL vs Name (Yazi 26.x)

In Yazi 26.x, `name` was renamed to `url` for all rules:

```toml
# Old (doesn't work in 26.x)
{ name = "*.csv", run = "bat" }

# New
{ url = "*.csv", run = "bat" }
```

Applies to `prepend_fetchers`, `prepend_preloaders`, `prepend_previewers`.

### Deprecated Lua APIs

Yazi 25.x/26.x deprecated several APIs:

| Old | New |
|-----|-----|
| `ya.manager_emit()` | `ya.emit()` |
| `ya.mgr_emit()` | `ya.emit()` |
| `ya.preview_widgets()` | `ya.preview_widget()` |
| `ya.render()` | `ui.render()` |
| `position` (in `ya.input`) | `pos` |

### Lua Sandbox Limitations

Yazi runs plugins in a sandboxed Lua environment. These standard Lua features
are **not available**:

| Unavailable | Workaround |
|-------------|------------|
| `debug` library | Use `ya.dbg()` for logging |
| `io.open()` | Use `Command` to spawn shell/python |
| `os.execute()` | Use `Command` API |
| `require()` for external modules | Inline code or use `Command` |

For custom binary parsing, use inline Python via
`Command("python3"):arg({"-c", script})`.

### Plugin Debugging

```lua
ya.dbg("message", data)  -- debug level
ya.err("message", data)  -- error level
```

```bash
YAZI_LOG=debug yazi
```

Log file: `~/.local/state/yazi/yazi.log`. Common silent-failure mode:
runtime errors in `Status:redraw` / `Header:redraw` only surface here, never
on screen. `tail -F` it (or `just -f yazi/justfile log`) when the UI is wrong.

**Sandbox + render path gotcha.** Yazi's sync/async/plugin split is
strict — three separate constraints conspire:

1. `Status:redraw` and `Header:redraw` are sync. Calling anything that
   yields (`Command:wait_with_output`, `child:wait_with_output`, …)
   throws `attempt to yield from outside a coroutine`.
2. `ps.sub` and its callback are also sync — same yield restriction.
3. `ya.sync(fn)` and `ps.sub` are **only callable from a plugin
   module**, not from `init.lua`. Putting them in `init.lua` throws
   `ya.sync() must be called in a plugin` / `sub() must be called in a
   sync plugin`.

Working topology for cwd-derived state:

```
ps.sub("cd")  ──► ya.async worker (Command IO)
              ──► ya.sync setter writes module cache + ya.render()
              ──► Status:redraw reads the cache (plain table get)
```

See `yazi/plugins/git-status.yazi/main.lua` for the canonical
implementation, then `require("git-status").get(cwd)` from
`Status:redraw`.

### Up-front Lua syntax check

`yazi` silently fails to load a file with bad Lua — there's no on-screen
error. Run `luac -p` before iterating in the TUI:

```bash
just -f yazi/justfile lint        # checks init.lua + worktree-jump
bun test yazi-lua-syntax          # in diagnostics/, same check
```

Sneaky failure: `[[ ... ]]` long-strings get terminated by *any* embedded
`]]` (e.g. awk's `t[a[1]]`). Use `[==[ ... ]==]` whenever the body might
contain `]]`.

### LSP / type stubs

Official type stubs from `yazi-rs/plugins:types` are tracked in
`yazi/package.toml` and a `.luarc.json` at `yazi/` points
`lua-language-server` at them — autocomplete and bad-call diagnostics for
`Command`, `ui.Span`, `cx`, `ps.sub`, etc. Refresh with
`ya pkg upgrade yazi-rs/plugins:types`.

### Justfile Recipes

| Recipe | Description |
|--------|-------------|
| `lint` | `luac -p` for our owned Lua (init.lua + worktree-jump) |
| `log` | `tail -F ~/.local/state/yazi/yazi.log` |
| `test <file>` | Capture yazi preview via tmux |
| `test-csv` | Test with sample CSV |
| `test-debug <file>` | With `YAZI_LOG=debug` |
| `debug-csv` | Full cycle: clear → inject debug → test → show log → cleanup |

### Fork and Submodule Workflow

To fix a third-party plugin and contribute upstream:

```bash
# 1. Fork
gh repo fork mgumz/yazi-plugin-bat --clone=false

# 2. Replace directory with submodule
rm -rf yazi/plugins/bat.yazi
git submodule add git@github.com:JamesKim2998/yazi-plugin-bat.git yazi/plugins/bat.yazi

# 3. Apply fixes in the submodule
cd yazi/plugins/bat.yazi
# ... edit files ...
git add . && git commit -m "fix: update deprecated APIs"
git push origin main

# 4. PR upstream
gh pr create --repo mgumz/yazi-plugin-bat --title "fix: ..." --body "..."

# 5. Commit submodule pointer in parent repo
cd ../../..
git add yazi/plugins/bat.yazi .gitmodules
git commit -m "yazi: add bat.yazi as submodule with fixes"
```

### MIME Detection Issues

MIME detection is often wrong (e.g. `.xlsx` detected as
`application/octet-stream`). URL-based rules first:

```toml
prepend_previewers = [
    { url = "*.xlsx", run = "xleak" },
    { mime = "application/vnd.openxmlformats-officedocument.*", run = "office" },
]
```
