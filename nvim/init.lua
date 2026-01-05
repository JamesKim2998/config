require("config.lazy")

-- Appearance
vim.cmd.colorscheme("kanagawa-wave")

-- Indentation
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
vim.o.tabstop = 2 -- Number of spaces a <Tab> counts for
vim.o.softtabstop = 2 -- Number of spaces a <Tab> counts for while editing
vim.o.smarttab = true -- recognizes some C syntax to increase/reduce the indent where appropriate.

-- UI
vim.o.cmdheight = 0 -- Hide command line when not in use
vim.o.number = true
vim.o.numberwidth = 1 -- Minimum width for number column
vim.o.signcolumn = "number" -- Show signs in number column
vim.o.showcmd = true -- Show command in the last line as it's being typed
vim.o.cursorline = true -- Highlight the current line
vim.o.showmatch = true -- Briefly jump to matching bracket when inserting one
vim.o.list = true -- Enable display of invisible characters (whitespace, tabs, etc.)
vim.o.listchars = "tab:▸ ,trail:·,extends:→,precedes:←,nbsp:␣"
vim.o.showtabline = 2 -- Always show tabline

-- Common Key Mappings
vim.keymap.set("n", "qq", ":q<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })

-- Navigation
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

-- Move lines up and down with Cmd+Shift+Up/Down
vim.keymap.set("n", "<D-S-Up>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<D-S-Down>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("v", "<D-S-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "<D-S-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

-- Map Cmd+X to cut the current line or visual selection
vim.keymap.set("n", "<D-x>", "dd", { desc = "Cut line" })
vim.keymap.set("v", "<D-x>", "d", { desc = "Cut selection" })
vim.keymap.set("i", "<D-x>", function()
	-- Get current line content and cursor position
	local line = vim.api.nvim_get_current_line()
	local cursor_col = vim.api.nvim_win_get_cursor(0)[2]

	if #line > 0 then
		vim.fn.setreg('"', line)
		vim.api.nvim_del_current_line()
		vim.api.nvim_put({ "" }, "l", true, true)
		vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], cursor_col })
	end
end, { desc = "Cut line" })

-- Substitute mappings
vim.keymap.set("n", "<leader>s", ":%s///<Left><Left>", { desc = "Substitute in file" })
vim.keymap.set("n", "<leader>sw", function()
	local word = vim.fn.expand("<cword>")
	vim.cmd(":%s/" .. word .. "//g<Left><Left>")
end, { desc = "Substitute Word under cursor" })

-- Filetype associations
vim.filetype.add({
	extension = {
		command = "sh",
	},
})

-- Etc
vim.o.scrolloff = 8
vim.o.clipboard = "unnamedplus" -- Use system clipboard
