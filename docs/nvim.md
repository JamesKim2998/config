# Neovim Config

IDE setup with Lazy.nvim plugin manager.

## Keymaps

### Files & Buffers

| Key | Action | Source |
|-----|--------|--------|
| `<leader>ff` | Find files | fzf-lua |
| `<leader>fg` | Live grep | fzf-lua |
| `<leader>fr` | Recent files | fzf-lua |
| `<leader>fw` | Grep word under cursor | fzf-lua |
| `<leader>fb` | Buffers | fzf-lua |
| `<leader><leader>` | Buffers (quick) | fzf-lua |
| `<Tab>` / `<S-Tab>` | Next/prev buffer | bufferline |
| `<leader>1-9` | Go to buffer N | bufferline |
| `<C-n>` | Toggle file explorer | neo-tree |
| `<leader>e` | Focus file explorer | neo-tree |
| `<leader>gs` | Git status (neo-tree) | neo-tree |
| `<leader>-` | Open yazi | yazi |
| `<leader>.` | New scratch buffer | snacks |
| `<leader>S` | Select scratch buffer | snacks |
| `<leader>sr` | Structural search/replace | ssr |

### neo-tree (inside explorer)

| Key | Action |
|-----|--------|
| `<` / `>` | Switch tabs (Files ↔ Git) |
| `/` | Fuzzy search files |
| `<CR>` | Open file/expand dir |
| `<space>` | Toggle node |
| `a` | Add file |
| `A` | Add directory |
| `d` | Delete |
| `r` | Rename |
| `y` | Copy file |
| `x` | Cut file |
| `p` | Paste |
| `Y` | Copy absolute path |
| `<BS>` | Navigate up |
| `?` | Show help |

### neo-tree Git tab

| Key | Action |
|-----|--------|
| `ga` | Stage file |
| `gu` | Unstage file |
| `gr` | Revert file |
| `gc` | Commit |
| `gp` | Push |

### diffview (inside diff view)

| Key | Action |
|-----|--------|
| `g<C-x>` | Cycle layouts |
| `<leader>b` | Toggle file panel |
| `<tab>` / `<S-tab>` | Next/prev file |
| `s` | Stage entry |
| `-` | Toggle stage |
| `X` | Discard changes |
| `Y` | Copy absolute path |
| `q` | Close and go to viewed file |

### fzf-lua (inside picker)

| Key | Action |
|-----|--------|
| `ctrl-y` | Copy file path to clipboard |
| `ctrl-q` | Send all to quickfix |
| `alt-i` | Toggle ignore (.gitignore) |
| `alt-h` | Toggle hidden files |
| `ctrl-u/d` | Half page up/down |

### Motion & Navigation

| Key | Action | Source |
|-----|--------|--------|
| `s` | Flash jump | flash |
| `r` | Remote flash (operator mode) | flash |
| `<c-s>` | Toggle flash in search | flash |
| `]]` / `[[` | Next/prev LSP reference | snacks.words |
| `gd` | Go to definition | trouble |
| `gr` | Go to references | trouble |
| `gI` | Go to implementation | trouble |
| `gy` | Go to type definition | trouble |
| `gD` | Go to declaration | lsp |
| `K` | Hover documentation | lsp |

### Diagnostics & Symbols

| Key | Action | Source |
|-----|--------|--------|
| `<leader>xx` | All diagnostics | trouble |
| `<leader>xX` | Buffer diagnostics | trouble |
| `<leader>xt` | TODOs | trouble |
| `<leader>cs` | Symbols (outline) | trouble |
| `<leader>ss` | Document symbols | fzf-lua |
| `<leader>sS` | Workspace symbols | fzf-lua |
| `<leader>cl` | LSP panel (right) | trouble |
| `<leader>xL` | Location list | trouble |
| `<leader>xQ` | Quickfix list | trouble |
| `[d` / `]d` | Prev/next diagnostic | lsp |
| `<leader>th` | Toggle inlay hints | lsp |
| `[t` / `]t` | Prev/next TODO | todo-comments |
| `<leader>ft` | Find TODOs | todo-comments |

### Editing

| Key | Action | Source |
|-----|--------|--------|
| `<M-j>` / `<M-k>` | Move line/block up/down | move.nvim |
| `<D-x>` | Cut line/selection | init.lua |
| `<leader>rn` | Rename symbol | lsp |
| `<leader>ca` | Code action | lsp |
| `<leader>f` | Format buffer | conform |
| `zR` / `zM` | Open/close all folds | ufo |
| `ys{motion}{char}` | Add surround | surround |
| `ds{char}` | Delete surround | surround |
| `cs{old}{new}` | Change surround | surround |

### Completion

| Key | Action | Source |
|-----|--------|--------|
| `<Tab>` | Accept AI suggestion | copilot |
| `<C-space>` | Show completion menu | blink.cmp |
| `<C-y>` | Accept completion | blink.cmp |
| `<C-e>` | Hide menu | blink.cmp |
| `<C-n>` / `<C-p>` | Navigate items | blink.cmp |

### Markdown

| Key | Action | Source |
|-----|--------|--------|
| `o` / `O` | List continuation (checkbox, bullet, numbered, blockquote) | markdown-lists |
| `<CR>` | List continuation in insert mode | markdown-lists |
| `<leader>tt` | Toggle checkbox `[ ]` ↔ `[x]` | markdown-lists |


### Session

| Key | Action | Source |
|-----|--------|--------|
| `<leader>qs` | Restore session | persistence |
| `<leader>qS` | Select session | persistence |
| `<leader>ql` | Restore last session | persistence |
| `<leader>qd` | Don't save session | persistence |

### General

| Key | Action | Source |
|-----|--------|--------|
| `<leader>w` | Save | init.lua |
| `qq` | Close buffer (quit if last) | init.lua |
| `Q` | Quit nvim | init.lua |
| `]<Space>` | Add line below | init.lua |
| `[<Space>` | Add line above | init.lua |
| `<leader>y` | Copy relative path | init.lua |
| `<leader>Y` | Copy absolute path | init.lua |
| `<leader>gg` | Lazygit | snacks |
| `<leader>gl` | Lazygit file log | snacks |
| `<leader>gd` | Toggle diff view | diffview |
| `<leader>gh` | File history | diffview |
| `<leader>gH` | Repo history | diffview |
| `]h` / `[h` | Next/prev hunk | gitsigns |
| `<leader>hs` | Stage hunk | gitsigns |
| `<leader>hr` | Reset hunk | gitsigns |
| `<leader>hu` | Undo stage hunk | gitsigns |
| `<leader>hS` | Stage buffer | gitsigns |
| `<leader>hR` | Reset buffer | gitsigns |
| `<leader>hp` | Preview hunk | gitsigns |
| `<leader>hb` | Blame line | gitsigns |
| `<leader>fh` | Help tags | fzf-lua |
| `<leader>fc` | Commands | fzf-lua |
| `<leader>fk` | Keymaps | fzf-lua |
| `<leader>?` | Buffer keymaps | which-key |

## Plugins

| Plugin | Purpose | File |
|--------|---------|------|
| **UI** |||
| treesitter-context | Sticky header (func/class) | plugins.lua |
| bufferline.nvim | Buffer tabs | bufferline.lua |
| noice.nvim | Messages/cmdline UI | noice.lua |
| nvim-scrollbar | Scrollbar | scrollbar.lua |
| snacks.nvim | Indent guides, scratch, notifier, LSP words, lazygit | snacks.lua |
| neo-tree.nvim | File explorer with git tab | neo-tree.lua |
| which-key.nvim | Keymap hints | which-key.lua |
| **Code** |||
| mason.nvim + lspconfig | LSP support | lsp.lua |
| blink.cmp | Completion | blink-cmp.lua |
| copilot.vim | AI completion | plugins.lua |
| conform.nvim | Formatting | conform.lua |
| nvim-lint | Linting | lint.lua |
| nvim-ufo | Code folding | ufo.lua |
| render-markdown.nvim | Markdown rendering | render-markdown.lua |
| vim-markdown | Indent (indentexpr for `==`) | vim-markdown.lua |
| markdown-lists (local) | List continuation, checkbox toggle, auto-renumber, strikethrough | markdown-lists.lua |
| **Editing** |||
| move.nvim | Move lines/blocks with Alt+j/k | move.lua |
| nvim-surround | Surround pairs | surround.lua |
| nvim-autopairs | Auto-close brackets | autopairs.lua |
| **Navigation** |||
| fzf-lua | Fuzzy finder | fzf-lua.lua |
| flash.nvim | Jump anywhere | flash.lua |
| trouble.nvim | Diagnostics, refs, quickfix | trouble.lua |
| todo-comments.nvim | TODO highlighting | todo-comments.lua |
| yazi.nvim | File manager | yazi.lua |
| ssr.nvim | Structural search/replace | ssr.lua |
| vim-kitty-navigator | Kitty/nvim panes | plugins.lua |
| kitty-scrollback.nvim | Scrollback in kitty | kitty-scrollback.lua |
| **Git** |||
| gitsigns.nvim | Inline signs, hunk staging | gitsigns.lua |
| diffview.nvim | Side-by-side diff, file history | diffview.lua |
| **Session** |||
| persistence.nvim | Session restore | persistence.lua |

## Code Quality Stack

| Stage | Plugin | Trigger |
|-------|--------|---------|
| Syntax | Built-in treesitter | FileType |
| LSP | mason + lspconfig | BufReadPre |
| Lint | nvim-lint | BufEnter, BufWritePost |
| Format | conform.nvim | BufWritePre, `<leader>f` |
| Completion | blink.cmp | InsertEnter |

Built-in parsers: `lua`, `vim`, `markdown`, `c`, `vimdoc`, `query`

## LSP Servers

| Language | Server | Notes |
|----------|--------|-------|
| Lua | lua_ls | Auto-enabled |
| TypeScript/JS | ts_ls | Inlay hints configured |
| C# | csharp_ls | Faster than OmniSharp, finds .sln upward |

Run `:Mason` to manage language servers. Servers in `ensure_installed` auto-install.

### E2E Tests

See [Plugin Testing](nvim-plugin-testing.md) for running and writing plugin tests.
