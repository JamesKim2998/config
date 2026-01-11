-- https://github.com/folke/snacks.nvim
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	init = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
	end,
	opts = {
		indent = { enabled = true },
		explorer = { enabled = true },
		picker = { sources = { explorer = { win = { list = { keys = { ["<C-n>"] = "close" } } } } } },
	},
	config = function(_, opts)
		require("snacks").setup(opts)
		local function toggle_explorer()
			local pickers = Snacks.picker.get({ source = "explorer" })
			if pickers and pickers[1] then pickers[1]:close() else Snacks.explorer() end
		end
		vim.keymap.set("n", "<C-n>", toggle_explorer, { desc = "Toggle Explorer" })
		vim.keymap.set("n", "<leader>e", function() Snacks.explorer() end, { desc = "Focus Explorer" })
	end,
}
