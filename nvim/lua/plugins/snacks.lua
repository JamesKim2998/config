-- https://github.com/folke/snacks.nvim
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		indent = { enabled = true },
		scratch = { enabled = true },
	},
	config = function(_, opts)
		require("snacks").setup(opts)
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
