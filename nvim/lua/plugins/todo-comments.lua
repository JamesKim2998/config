-- https://github.com/folke/todo-comments.nvim
-- Highlight and search TODO/FIXME/HACK comments
return {
	"folke/todo-comments.nvim",
	event = "BufReadPost",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {},
	keys = {
		{ "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
		{ "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
		{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs (Trouble)" },
		{ "<leader>ft", "<cmd>TodoFzfLua<cr>", desc = "Find TODOs" },
	},
}
