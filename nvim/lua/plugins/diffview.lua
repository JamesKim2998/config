-- https://github.com/sindrets/diffview.nvim

-- Track last viewed file path across view close
local last_file_path = nil

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
		enhanced_diff_hl = true, -- Better diff highlighting
		file_panel = {
			win_config = { width = 25 },
			listing_style = "list", -- Flat list (simpler than tree for small changesets)
		},
		hooks = {
			view_leave = function(view)
				local ok, file = pcall(function() return view:infer_cur_file() end)
				last_file_path = ok and file and file.absolute_path or nil
			end,
			view_closed = function()
				if last_file_path and vim.fn.filereadable(last_file_path) == 1 then
					vim.cmd("edit " .. vim.fn.fnameescape(last_file_path))
				end
				last_file_path = nil
			end,
		},
		keymaps = {
			view = { ["<leader>e"] = false, ["q"] = "<cmd>DiffviewClose<cr>" },
			file_panel = {
				["<leader>e"] = false,
				["q"] = "<cmd>DiffviewClose<cr>",
				{
					"n", "Y",
					function()
						local lib = require("diffview.lib")
						local view = lib.get_current_view()
						local file = view and view:infer_cur_file()
						if file and file.absolute_path then
							vim.fn.setreg("+", file.absolute_path)
							vim.notify("Copied: " .. file.absolute_path)
						end
					end,
					{ desc = "Copy absolute path" },
				},
			},
			file_history_panel = {
				["q"] = "<cmd>DiffviewClose<cr>",
				{
					"n", "Y",
					function()
						local lib = require("diffview.lib")
						local view = lib.get_current_view()
						local file = view and view:infer_cur_file()
						if file and file.absolute_path then
							vim.fn.setreg("+", file.absolute_path)
							vim.notify("Copied: " .. file.absolute_path)
						end
					end,
					{ desc = "Copy absolute path" },
				},
			},
		},
	},
}
