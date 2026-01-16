-- https://github.com/folke/trouble.nvim
-- Pretty diagnostics, references, quickfix list
return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "Trouble",
	keys = {
		-- Official recommended keymaps
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
		{ "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
		{ "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions/References (Trouble)" },
		{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
		{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
		-- LSP navigation
		{ "gr", "<cmd>Trouble lsp_references toggle<cr>", desc = "References (Trouble)" },
		{ "gI", "<cmd>Trouble lsp_implementations toggle<cr>", desc = "Implementations (Trouble)" },
		{ "gd", "<cmd>Trouble lsp_definitions toggle<cr>", desc = "Definitions (Trouble)" },
		{ "gy", "<cmd>Trouble lsp_type_definitions toggle<cr>", desc = "Type Definitions (Trouble)" },
	},
	opts = {
		auto_close = true, -- Auto close when no items
		auto_preview = true, -- Auto preview on cursor move
		focus = true, -- Focus trouble window when opened
		follow = true, -- Follow cursor position
	},
}
