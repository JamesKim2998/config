return {
	-- appearance
	{ "rebelot/kanagawa.nvim", priority = 1000 },
	{ "folke/tokyonight.nvim", priority = 1000 },

	-- treesitter (syntax parsing)
	{
		"nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({ "json", "typescript", "tsx" })
		end,
	},

	-- context (sticky header)
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufReadPost",
		opts = {
			max_lines = 3,
			multiline_threshold = 1,
		},
	},

	-- navigation between kitty and nvim splits
	{ "knubie/vim-kitty-navigator" },
}
