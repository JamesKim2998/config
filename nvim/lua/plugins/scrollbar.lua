-- Scrollbar with colored indicators for git changes, diagnostics, and search matches
return {
	"petertriho/nvim-scrollbar",
	event = "BufReadPost",
	dependencies = {
		"lewis6991/gitsigns.nvim", -- git change indicators
		"kevinhwang91/nvim-hlslens", -- search match indicators
	},
	config = function()
		require("scrollbar").setup({
			handlers = {
				cursor = true,
				diagnostic = true,
				gitsigns = true,
				search = true,
			},
		})
		require("scrollbar.handlers.gitsigns").setup()
		require("scrollbar.handlers.search").setup()
	end,
}
