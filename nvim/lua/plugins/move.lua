return {
	"fedepujol/move.nvim",
	keys = {
		{ "<M-j>", "<cmd>MoveLine(1)<CR>", desc = "Move line down" },
		{ "<M-k>", "<cmd>MoveLine(-1)<CR>", desc = "Move line up" },
		{ "<M-j>", "<cmd>MoveBlock(1)<CR>", mode = "v", desc = "Move block down" },
		{ "<M-k>", "<cmd>MoveBlock(-1)<CR>", mode = "v", desc = "Move block up" },
	},
	opts = {
		char = { enable = false },
		word = { enable = false },
	},
}
