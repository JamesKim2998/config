# VS Code Config

Global settings live in `vscode/` (symlinked to `Code/User/`). Each repo adds a `.vscode/settings.json` workspace layer.

> **Related:** [[CLAUDE.md]] (repo table)

## Window Identity

With 5+ windows open, the title alone is unreadable in Mission Control and `Cmd+\``. Each repo's workspace layer carries two markers:

- an emoji prefix on `window.title`
- a `titleBar.*` tint via `workbench.colorCustomizations`

### Tint Palette

Generated in [OKLCH](https://bottosson.github.io/posts/oklab/), which keeps lightness and chroma perceptually uniform across hues — the same values in HSL would make yellow glare and blue vanish.

- **Lightness is fixed, hue does the work.** Active sits at `L=0.330`, matching Kanagawa's `sumiInk5` (`#363646`); inactive at `L=0.278`, just above the editor background `sumiInk3` (`#1F1F28`). The bar reads as tinted chrome, not as a colored banner.
- **Chroma is constant at `C=0.052`** — capped by cyan, the tightest hue in sRGB at this lightness. Equal chroma means no window shouts louder than the others.
- **Foregrounds are the theme's own** `fujiWhite` / a dimmed `oldWhite`, holding ≥8:1 on active and ≥5:1 on inactive.

Hues are spaced 36° apart (`h = 25 + 36k`) so no two are confusable — take an unused slot when adding a repo:

| Repo | Hue | Active | Inactive |
|------|-----|--------|----------|
| boxcat-rust-tools 🦀 | 25 red | `#4D2A28` | `#38211F` |
| meow-tower 🐱 | 61 orange | `#492F18` | `#352416` |
| meow-toolbox 🧰 | 97 olive | `#3D3513` | `#2D2813` |
| meow-langpack 🌐 | 133 green | `#2B3B1F` | `#212C1A` |
| config ⚙️ | 169 teal | `#153E31` | `#152E25` |
| meow-infra ☁️ | 205 cyan | `#093D42` | `#0F2D31` |
| meow-game-server 🖥️ | 241 blue | `#1A394E` | `#172B39` |
| pspec 🧩 | 277 violet | `#2F3350` | `#24273A` |
| meow-assets 🎨 | 313 magenta | `#3F2D48` | `#2F2335` |
| meow-dev-media 🖼️ | 349 pink | `#492A3A` | `#36212B` |

Tuned for the dark scheme; `window.autoDetectColorScheme` also switches to Kanagawa Lotus, where these read as dark bars with light text — legible, but inverted from the surrounding light chrome.

The tint needs no extra flag — [`window.titleBarStyle`](https://code.visualstudio.com/docs/configure/custom-layout#_title-bar) already defaults to `custom` on macOS. A `native` title bar cannot be colored, so set it back to `custom` globally if that default ever changes.
