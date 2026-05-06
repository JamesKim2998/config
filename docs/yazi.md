# Yazi Config

File manager with plugins, custom keymaps, and previewers.

> **Related:** [[nvim-plugin-testing.md]] (shared test harness)

## Custom Keymaps

| Key | Action |
|-----|--------|
| `q` | Close tab (quit if last) |
| `Tab` / `S-Tab` | Next/prev tab |
| `i` | File info (spot) |
| `/` | Filter files (smart) |
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
bun run yazi                        # all yazi-*.test.ts
```

### Detecting which opener fired

Yazi spawns the opener as a child process. To tell whether `edit` or `open`
ran without launching a real editor or Finder window, the test:

1. Writes shim scripts at `${TEST_DIR}/bin/{open,fake-editor}` that just
   `touch` a marker file.
2. Launches yazi via `tmux new-session ... sh -c 'EDITOR=… PATH=…/bin:$PATH
   exec yazi'`. The shell wrapper is needed because tmux's `-e` flag is
   shadowed by `update-environment`.
3. Sends keys, then asserts which marker exists.

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

Log file: `~/.local/state/yazi/yazi.log`

### Justfile Recipes

| Recipe | Description |
|--------|-------------|
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
