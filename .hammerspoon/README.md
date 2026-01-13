# Hammerspoon Configuration

macOS automation with Lua scripting.

## Hotkeys

All app hotkeys use `Cmd+Opt+Ctrl` (mash_app) prefix.

### App Launchers

| Key | App |
|-----|-----|
| A | Android Studio |
| C | Google Chrome |
| F | Finder |
| K | Fork |
| N | Notes |
| O | Obsidian |
| R | Rider |
| S | Slack |
| T | TexturePacker |
| U | Unity (custom launcher) |
| V | Visual Studio Code |
| W | WebStorm |
| X | Xcode |
| Y | kitty |

### Mouse Control

| Key | Action |
|-----|--------|
| Cmd+Opt+Ctrl+P | Warp mouse to center of focused window |
| Cmd+Opt+Ctrl+; | Toggle vimouse mode |

### Vimouse Mode

Source: [tweekmonster/hammerspoon-vimouse](https://github.com/tweekmonster/hammerspoon-vimouse) (modified)

Right-hand friendly controls:

| Key | Action |
|-----|--------|
| h/j/k/l | Move 20px |
| Shift + h/j/k/l | Move 100px (fast) |
| Alt + h/j/k/l | Move 5px (slow) |
| b/f | Scroll up/down (vim-style) |
| Shift + b/f | Scroll fast |
| Alt + b/f | Scroll slow |
| p | Warp to focused window |
| Space | Left click (hold = drag) |
| Ctrl + Space | Right click |
| i or ESC | Exit mode |

## Files

| File | Description |
|------|-------------|
| `init.lua` | Entry point, loads modules |
| `hotkey.lua` | App launchers and mouse control |
| `vimouse.lua` | Vim-style mouse control plugin |
