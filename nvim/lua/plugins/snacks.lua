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
		scratch = { enabled = true },
		picker = {
			sources = {
				explorer = {
					matcher = { fuzzy = true, filename = true }, -- match filename only
					auto_close = false,
					layout = { auto_hide = { "input" } }, -- show search box only on /
					formatters = { idx = false }, -- hide item numbers
					win = { list = { keys = { ["<C-n>"] = "close" } } }, -- match toggle key
					exclude = { "*.png" },
				},
			},
		},
	},
	config = function(_, opts)
		require("snacks").setup(opts)
		local function toggle_explorer()
			local pickers = Snacks.picker.get({ source = "explorer" })
			if pickers and pickers[1] then pickers[1]:close() else Snacks.explorer() end
		end
		vim.keymap.set("n", "<C-n>", toggle_explorer, { desc = "Toggle Explorer" })
		vim.keymap.set("n", "<leader>e", function() Snacks.explorer() end, { desc = "Focus Explorer" })
		vim.keymap.set("n", "<leader>.", function()
			local scratch_dir = vim.fn.stdpath("data") .. "/scratch"
			vim.fn.mkdir(scratch_dir, "p")
			local ext = vim.fn.expand("%:e")
			if ext == "" then ext = "txt" end
			local file = scratch_dir .. "/scratch_" .. os.date("%Y%m%d_%H%M%S") .. "." .. ext
			vim.cmd("e " .. file)
		end, { desc = "New Scratch" })
		vim.keymap.set("n", "<leader>S", function()
			local scratch_dir = vim.fn.stdpath("data") .. "/scratch"
			Snacks.picker.files({ cwd = scratch_dir })
		end, { desc = "Select Scratch" })
	end,
}
