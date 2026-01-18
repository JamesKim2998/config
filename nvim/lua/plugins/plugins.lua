return {
	-- appearance
	{ "rebelot/kanagawa.nvim", priority = 1000 },
	{ "folke/tokyonight.nvim", priority = 1000 },

	-- git
	{ "lewis6991/gitsigns.nvim", event = "BufReadPost", opts = {} },

	-- autocomplete
	{
		"github/copilot.vim",
		lazy = false,
		init = function()
			vim.g.copilot_node_command = "/opt/homebrew/bin/node"
			vim.g.copilot_no_tab_map = true -- Distinguish real Tab from Ctrl+I (Kitty CSI u)
		end,
		config = function()
			vim.keymap.set("i", "<Tab>", 'copilot#Accept("<CR>")', { expr = true, replace_keycodes = false }) -- Only real Tab accepts
		end,
	},

	-- navigation between kitty and nvim splits
	{ "knubie/vim-kitty-navigator" },
}
