# Yazi Configuration

## Plugins

| Plugin | Purpose |
|--------|---------|
| bat.yazi | Syntax-highlighted text preview |
| xleak.yazi | Fast Excel preview (uses xleak) |
| office.yazi | Office document preview (LibreOffice) |
| ouch.yazi | Archive preview/compression |
| mediainfo.yazi | Media file info/preview |
| git.yazi | Git status in file list |
| mactag.yazi | macOS Finder tags |

## Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| bat | Syntax highlighting | `brew install bat` |
| xleak | Excel preview | `cargo install xleak` |
| poppler | PDF preview (pdftoppm) | `brew install poppler` |
| libreoffice | Office document conversion | `brew install --cask libreoffice` |
| ouch | Archive handling | `brew install ouch` |
| mediainfo | Media file info | `brew install mediainfo` |

## Configuration Notes

### URL vs Name (Yazi 26.x)

In Yazi 26.x, `name` was renamed to `url` for all rules:

```toml
# Old (doesn't work in 26.x)
{ name = "*.csv", run = "bat" }

# New (correct)
{ url = "*.csv", run = "bat" }
```

This applies to:
- `prepend_fetchers`
- `prepend_preloaders`
- `prepend_previewers`

### Deprecated APIs

Yazi 25.x/26.x deprecated several Lua APIs:

| Old | New |
|-----|-----|
| `ya.manager_emit()` | `ya.emit()` |
| `ya.mgr_emit()` | `ya.emit()` |
| `ya.preview_widgets()` | `ya.preview_widget()` |
| `ya.render()` | `ui.render()` |
| `position` (in ya.input) | `pos` |

### Plugin Debugging

1. Add debug logging:
```lua
ya.dbg("message", data)  -- debug level
ya.err("message", data)  -- error level
```

2. Run yazi with logging:
```bash
YAZI_LOG=debug yazi
```

3. Check log file:
```
~/.local/state/yazi/yazi.log
```

### MIME Detection Issues

MIME detection is often wrong (e.g., xlsx detected as `application/octet-stream`).
Use URL-based rules first to ensure correct matching:

```toml
prepend_previewers = [
    # URL rules first (always match by extension)
    { url = "*.xlsx", run = "xleak" },
    # MIME rules as fallback
    { mime = "application/vnd.openxmlformats-officedocument.*", run = "office" },
]
```

## Custom Plugins

### xleak.yazi

Fast Excel preview using [xleak](https://github.com/bgreenwell/xleak) (Rust-based).

Install xleak:
```bash
cargo install xleak
```
