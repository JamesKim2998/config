-- https://github.com/ibhagwan/fzf-lua
return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- File icons in picker
	event = "VeryLazy", -- Load after startup for faster init
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
		{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
		{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
		{ "<leader>fw", "<cmd>FzfLua grep_cword<cr>", desc = "Grep word under cursor" },
		-- diagnostics/symbols moved to trouble.nvim
		{ "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
		{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
		{ "<leader><leader>", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
	},
	opts = {},
}
