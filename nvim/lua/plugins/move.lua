return {
	"fedepujol/move.nvim",
	keys = {
		{ "<M-j>", ":MoveLine(1)<CR>", desc = "Move line down" },
		{ "<M-k>", ":MoveLine(-1)<CR>", desc = "Move line up" },
		{ "<M-j>", ":MoveBlock(1)<CR>", mode = "v", desc = "Move block down" },
		{ "<M-k>", ":MoveBlock(-1)<CR>", mode = "v", desc = "Move block up" },
	},
	opts = {
		char = { enable = false },
		word = { enable = false },
	},
}
