-- https://github.com/kevinhwang91/nvim-ufo
return {
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	event = "BufReadPost", -- Load when a real file is opened
	init = function()
		vim.o.foldcolumn = "1" -- show a column with fold markers
		vim.o.foldlevel = 99 -- start with all folds open
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
	end,
	keys = {
		{
			"zR",
			function()
				require("ufo").openAllFolds()
			end,
			desc = "UFO: open all folds",
		},
		{
			"zM",
			function()
				require("ufo").closeAllFolds()
			end,
			desc = "UFO: close all folds",
		},
	},
	config = function()
		require("ufo").setup({
			provider_selector = function(_, _)
				return { "treesitter", "indent" }
			end,
		})
	end,
}
