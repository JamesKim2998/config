-- Disable node provider (using Bun's wrapper, Copilot has its own node path)
vim.g.loaded_node_provider = 0

require("config.lazy")

-- Appearance: use THEME_NVIM env var, fallback to kanagawa
vim.cmd.colorscheme(vim.env.THEME_NVIM or "kanagawa-wave")

-- Indentation
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
vim.o.tabstop = 2 -- Number of spaces a <Tab> counts for
vim.o.softtabstop = 2 -- Number of spaces a <Tab> counts for while editing
vim.o.smarttab = true -- recognizes some C syntax to increase/reduce the indent where appropriate.

-- Statusline (native, replaces lualine)
local mode_icons = {
	n = "󰆾", i = "󰏫", v = "󰒉", V = "󰒉", [""] = "󰒉",
	R = "󰛔", c = "󰘳", t = "󰆍", s = "󰒉", S = "󰒉",
}
function _G.statusline()
	if vim.bo.filetype == "neo-tree" then return "%#NeoTreeNormal#" end
	local mode = mode_icons[vim.fn.mode()] or vim.fn.mode()
	local branch = vim.b.gitsigns_head and ("   " .. vim.b.gitsigns_head) or ""
	return " " .. mode .. branch .. "%=%p%%  %l:%c "
end
vim.o.statusline = "%{%v:lua.statusline()%}"

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
vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "qq", function()
	local current = vim.api.nvim_get_current_buf()
	local bufs = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted and vim.api.nvim_buf_is_loaded(b) and b ~= current
	end, vim.api.nvim_list_bufs())
	if #bufs == 0 then
		vim.cmd("qa")
	else
		-- Switch to another listed buffer first, then delete current
		vim.api.nvim_set_current_buf(bufs[1])
		vim.cmd("bdelete " .. current)
	end
end, { desc = "Close buffer (quit if last)" })
vim.keymap.set("n", "Q", "<cmd>qa<CR>", { desc = "Quit nvim" })
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>y", function() vim.fn.setreg("+", vim.fn.expand("%")) end, { desc = "Copy relative path" })
vim.keymap.set("n", "<leader>Y", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, { desc = "Copy absolute path" })

-- Add newline without entering insert mode (remap=true to trigger buffer-local o/O)
vim.keymap.set("n", "]<Space>", "o<Esc>", { desc = "Add line below", remap = true })
vim.keymap.set("n", "[<Space>", "O<Esc>", { desc = "Add line above", remap = true })

-- Navigation
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

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
		plist = "xml",
	},
})

-- Enable treesitter highlighting (built-in, no plugin needed)
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

-- Search
vim.o.ignorecase = true -- Case insensitive search
vim.o.smartcase = true -- Unless uppercase typed

-- Etc
vim.o.scrolloff = 8
vim.o.clipboard = "unnamedplus"
vim.o.undofile = true -- Persistent undo history

-- Use OSC 52 for clipboard over SSH (yank reaches local clipboard)
if vim.env.SSH_TTY then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end
