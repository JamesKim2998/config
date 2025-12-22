-- https://github.com/folke/noice.nvim
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		cmdline = { view = "cmdline" }, -- bottom cmdline (use "cmdline_popup" for centered)
		messages = { view = "mini" }, -- minimal floating messages
		popupmenu = { enabled = false }, -- use default cmp/blink popupmenu
		lsp = {
			progress = { enabled = false }, -- disable if using fidget.nvim or similar
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},
	},
}
