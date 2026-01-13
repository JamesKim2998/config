# Karabiner-Elements Configuration

## Manual Sync Required

Karabiner-Elements replaces symlinks with regular files when saving. Use `just` commands to sync.

```bash
just import  # ~/.config/karabiner/karabiner.json -> repo
just export  # repo -> ~/.config/karabiner/karabiner.json
```

## Devices

| Device | VID | PID | Connection |
|--------|-----|-----|------------|
| Default (all keyboards) | - | - | - |
| Lenovo TrackPoint II (trackpad) | 6127 (0x17EF) | 24801 (0x60E1) | USB |
| Lenovo TrackPoint II (keyboard) | 6127 (0x17EF) | 24814 (0x60EE) | USB |
| Mistel MD770 | 2652 (0x0A5C) | 34050 (0x8502) | Bluetooth |
| Mistel MD770 | 1241 (0x04D9) | 1049 (0x0419) | USB |
### Finding Device IDs

```bash
# USB devices
ioreg -p IOUSB -w0 -l | grep -E '"USB Product Name"|"idProduct"|"idVendor"'

# Bluetooth devices
system_profiler SPBluetoothDataType | grep -E "Minor Type|Vendor ID|Product ID"
```

## Key Mappings

### Default (all keyboards)
- Caps Lock -> Escape
- Escape -> Fn (for Fn+HJKL arrows)
- Right Command -> F16 (input source switching)

### Lenovo TrackPoint II
- Caps Lock -> Escape
- Escape -> Fn (for Fn+HJKL arrows)
- Left Command <-> Left Option (swap for Mac layout)
- Right Command -> F16 (input source switching)
- Right Option -> F16 (input source switching)
- Button3 -> disabled (trackpad model)

### Mistel MD770 (Bluetooth & USB)
- Caps Lock -> Escape
- Escape -> Fn (for Fn+HJKL arrows)
- Right Command -> F16 (input source switching)
- See [barocco_md770.pdf](barocco_md770.pdf) for DIP switch settings

## Complex Modifications

### Fn + HJKL -> Arrow Keys (Vim-style)
- Fn + H -> Left
- Fn + J -> Down
- Fn + K -> Up
- Fn + L -> Right

### Fn + UIOP -> Mouse Movement
- Fn + U -> Mouse left
- Fn + I -> Mouse up
- Fn + O -> Mouse down
- Fn + P -> Mouse right

### Fn + [] -> Scroll
- Fn + [ -> Scroll up
- Fn + ] -> Scroll down

### Fn + ;' -> Page Up/Down
- Fn + ; -> Page up
- Fn + ' -> Page down

### Fn + Space -> Click
- Fn + Space -> Left click
- Fn + Ctrl + Space -> Right click

### Fn + Y -> Warp Mouse
- Fn + Y -> Warp mouse to center of focused window (via Hammerspoon)
