# Neovim Plugin Documentation

## Plugin Overview

| Plugin | Purpose | File |
|--------|---------|------|
| **UI** |||
| catppuccin/nvim | Colorscheme | plugins.lua |
| lualine.nvim | Statusline | plugins.lua |
| bufferline.nvim | Buffer tabs | bufferline.lua |
| noice.nvim | Messages/cmdline UI | noice.lua |
| snacks.nvim | Indent guides | snacks.lua |
| **Code Intelligence** |||
| nvim-treesitter | Syntax highlighting | nvim-treesitter.lua |
| mason.nvim + lspconfig | LSP support | lsp.lua |
| blink.cmp | Completion engine | blink-cmp.lua |
| copilot.vim | AI completion | plugins.lua |
| conform.nvim | Formatting | conform.lua |
| nvim-lint | Linting | lint.lua |
| nvim-ufo | Code folding | ufo.lua |
| **Navigation** |||
| fzf-lua | Fuzzy finder | fzf-lua.lua |
| nvim-tree.lua | File explorer | nvim-tree.lua |
| yazi.nvim | File manager | yazi.lua |
| nvim-spectre | Search & replace | spectre.lua |
| vim-kitty-navigator | Kitty/nvim navigation | plugins.lua |
| **Git** |||
| gitsigns.nvim | Git diff signs | plugins.lua |
| lazygit.nvim | Git TUI | lazygit.lua |

---

## Keybindings

### Search
| Key | Action | Plugin |
|-----|--------|--------|
| `<leader>ff` | Find files | fzf-lua |
| `<leader>fg` | Live grep | fzf-lua |
| `<leader>fw` | Grep word under cursor | fzf-lua |
| `<leader>fr` | Recent files | fzf-lua |
| `<leader>fd` | Document diagnostics | fzf-lua |
| `<leader>fs` | Document symbols | fzf-lua |
| `<leader>fh` | Help tags | fzf-lua |
| `<leader>fc` | Commands | fzf-lua |
| `<leader>fk` | Keymaps | fzf-lua |
| `<leader>S` | Search & replace | spectre |
| `<leader>sp` | Search in current file | spectre |
| `<leader>s` | Substitute | init.lua |
| `<leader>sw` | Substitute word | init.lua |

### Navigation
| Key | Action | Plugin |
|-----|--------|--------|
| `<leader>fb` | Buffers | fzf-lua |
| `<leader><leader>` | Buffers (quick) | fzf-lua |
| `<Tab>` / `<S-Tab>` | Next/prev buffer | bufferline |
| `<leader>1-9` | Go to buffer N | bufferline |
| `<C-n>` | Toggle file tree | nvim-tree |
| `<leader>-` | Open file manager | yazi |
| `<leader>cw` | Open yazi at cwd | yazi |
| `<C-Up>` | Resume yazi session | yazi |
| `gd` | Go to definition | lsp |
| `gD` | Go to declaration | lsp |
| `gr` | Go to references | lsp |
| `gI` | Go to implementation | lsp |
| `gy` | Go to type definition | lsp |
| `[d` / `]d` | Prev/next diagnostic | lsp |

### Editing
| Key | Action | Plugin |
|-----|--------|--------|
| `<leader>f` | Format buffer | conform |
| `<leader>rn` | Rename symbol | lsp |
| `<leader>ca` | Code action | lsp |
| `K` | Hover docs | lsp |
| `zR` / `zM` | Open/close folds | ufo |
| `<D-S-Up/Down>` | Move line up/down | init.lua |
| `<D-x>` | Cut line | init.lua |

### Completion
| Key | Action | Plugin |
|-----|--------|--------|
| `<Tab>` | Accept AI suggestion | copilot |
| `<C-space>` | Show completion menu | blink.cmp |
| `<C-y>` | Accept completion | blink.cmp |
| `<C-e>` | Hide menu | blink.cmp |
| `<C-n>` / `<C-p>` | Navigate items | blink.cmp |

### General
| Key | Action | Plugin |
|-----|--------|--------|
| `qq` | Quit | init.lua |
| `<leader>w` | Save | init.lua |
| `<leader>lg` | Open LazyGit | lazygit |

---

## Code Quality Stack

| Stage | Plugin | Trigger |
|-------|--------|---------|
| Syntax | nvim-treesitter | FileType |
| LSP | mason + lspconfig | BufReadPre |
| Lint | nvim-lint | BufEnter, BufWritePost |
| Format | conform.nvim | BufWritePre, `<leader>f` |
| Completion | blink.cmp | InsertEnter |

---

## File Structure (alphabetically sorted)

```
nvim/
├── init.lua
└── lua/
    ├── config/lazy.lua
    └── plugins/
        ├── blink-cmp.lua
        ├── bufferline.lua
        ├── conform.lua
        ├── fzf-lua.lua
        ├── lazygit.lua
        ├── lint.lua
        ├── lsp.lua
        ├── noice.lua
        ├── nvim-tree.lua
        ├── nvim-treesitter.lua
        ├── plugins.lua
        ├── snacks.lua
        ├── spectre.lua
        ├── ufo.lua
        └── yazi.lua
```
