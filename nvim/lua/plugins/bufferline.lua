return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "VeryLazy",
	keys = {
		-- cycle
		{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
		{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
		-- generate <leader>1-9 dynamically:
		unpack((function()
			local ks = {}
			for i = 1, 9 do
				table.insert(ks, {
					("<leader>%d"):format(i),
					function()
						require("bufferline").go_to(i, true)
					end,
					desc = "Go to tab " .. i,
				})
			end
			return ks
		end)()),
	},
	opts = {
		options = {
			diagnostics = "nvim_lsp",
			custom_filter = function(buf_number)
				local buf_name = vim.fn.bufname(buf_number)
				return not buf_name:match("NvimTree") -- hide NvimTree from tabline
			end,
		},
	},
}
