-- https://github.com/folke/which-key.nvim
-- Shows available keymaps after pressing leader
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "helix",
		delay = 300,
		icons = { mappings = false },
		spec = {
			{ "<leader>f", group = "find" },
			{ "<leader>x", group = "diagnostics" },
			{ "<leader>c", group = "code" },
			{ "<leader>o", group = "obsidian" },
			{ "<leader>q", group = "session" },
		},
	},
	keys = {
		{ "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Keymaps" },
	},
}
