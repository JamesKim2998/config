-- https://github.com/folke/noice.nvim
-- Handles cmdline, messages, popupmenu (notifications handled by snacks.notifier)
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},
		-- Route notifications to vim.notify (handled by snacks.notifier)
		routes = {
			{ filter = { event = "notify" }, view = "notify" },
		},
		presets = {
			bottom_search = true,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = true,
			lsp_doc_border = false,
		},
	},
}
