require("config.lazy")

-- Appearance
vim.cmd.colorscheme "catppuccin"

-- Indentation vim.o.tabstop = 4 vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- UI
vim.o.number = true
vim.o.showcmd = true -- Show command in the last line as it's being typed
vim.o.cursorline = true -- Highlight the current line
vim.o.showmatch = true -- Briefly jump to matching bracket when inserting one
vim.o.list = true -- Enable display of invisible characters (whitespace, tabs, etc.)
vim.o.listchars = "tab:▸ ,trail:·,extends:→,precedes:←,nbsp:␣"
vim.o.showtabline = 2 -- Always show tabline


-- Common Key Mappings
vim.keymap.set("n", "qq", ":q<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<D-S-Up>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<D-S-Down>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("v", "<D-S-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "<D-S-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

-- Etc
vim.o.scrolloff = 8
vim.o.clipboard = "unnamedplus" -- Use system clipboard

-- lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
})
