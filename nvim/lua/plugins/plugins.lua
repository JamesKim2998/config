return {
	-- appearance
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

	-- git
	{ "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
	{ "lewis6991/gitsigns.nvim" },

	-- autocomplete
	{ "github/copilot.vim", lazy = false },
}
