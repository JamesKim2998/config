return {
	-- appearance
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				disabled_filetypes = { statusline = { "NvimTree" } },
				section_separators = "",
				component_separators = "",
			},
			sections = {
				lualine_c = {},
				lualine_x = {},
			},
		},
	},

	-- git
	{ "lewis6991/gitsigns.nvim", opts = {} },

	-- autocomplete
	{ "github/copilot.vim", lazy = false },

	-- navigation between kitty and nvim splits
	{ "knubie/vim-kitty-navigator" },
}
