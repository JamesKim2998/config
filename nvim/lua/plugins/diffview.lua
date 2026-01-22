-- https://github.com/sindrets/diffview.nvim
return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	keys = {
		{ "<leader>gd", function()
			if next(require("diffview.lib").views) == nil then
				vim.cmd("DiffviewOpen")
			else
				vim.cmd("DiffviewClose")
			end
		end, desc = "Toggle diff view" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
	},
	opts = {
		file_panel = { win_config = { width = 25 } },
		keymaps = {
			view = { ["<leader>e"] = false, ["q"] = "<cmd>DiffviewClose<cr>" },
			file_panel = { ["<leader>e"] = false, ["q"] = "<cmd>DiffviewClose<cr>" },
			file_history_panel = { ["q"] = "<cmd>DiffviewClose<cr>" },
		},
	},
}
