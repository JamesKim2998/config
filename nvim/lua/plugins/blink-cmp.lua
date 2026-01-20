-- https://cmp.saghen.dev/installation
return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },
	version = "1.*",
	event = "InsertEnter",
	opts = {
		enabled = function()
			return vim.bo.filetype ~= "markdown"
		end,
		keymap = { preset = "default" },
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			documentation = { auto_show = true },
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
	},
	opts_extend = { "sources.default" }, -- Allow other specs to extend sources
}
