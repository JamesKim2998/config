-- https://github.com/folke/snacks.nvim
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		indent = { enabled = true },
		scratch = { enabled = true },
		notifier = { enabled = true },
		words = { enabled = true },
		lazygit = {}, -- auto-configures colorscheme + nvim-remote editing
	},
	config = function(_, opts)
		require("snacks").setup(opts)
		-- LSP reference navigation (snacks.words)
		vim.keymap.set("n", "]]", function() Snacks.words.jump(1, true) end, { desc = "Next reference" })
		vim.keymap.set("n", "[[", function() Snacks.words.jump(-1, true) end, { desc = "Prev reference" })
		-- Lazygit
		vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
		vim.keymap.set("n", "<leader>gl", function() Snacks.lazygit.log_file() end, { desc = "Lazygit file log" })
		-- Scratch files
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
