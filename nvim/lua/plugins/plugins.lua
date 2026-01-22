return {
	-- appearance
	{ "rebelot/kanagawa.nvim", priority = 1000 },
	{ "folke/tokyonight.nvim", priority = 1000 },

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
