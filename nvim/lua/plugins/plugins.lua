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
		end,
	},

	-- bullet lists
	{ "bullets-vim/bullets.vim" },

	-- navigation between kitty and nvim splits
	{ "knubie/vim-kitty-navigator" },
}
