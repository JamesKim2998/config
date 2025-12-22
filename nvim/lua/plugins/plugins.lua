return {
	-- appearance
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

	-- statusline
	{ "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },

	-- git
	{ "lewis6991/gitsigns.nvim", opts = {} },

	-- autocomplete
	{ "github/copilot.vim", lazy = false },

	-- navigation between kitty and nvim splits
	{ "knubie/vim-kitty-navigator" },
}
