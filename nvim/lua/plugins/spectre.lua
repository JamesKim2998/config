return {
	"nvim-pack/nvim-spectre",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<leader>S", function() require("spectre").toggle() end, desc = "Toggle Spectre" },
		{ "<leader>sp", function() require("spectre").open_file_search({select_word=true}) end, desc = "Search on current file" },
	},
	opts = {},
}
