-- https://cmp.saghen.dev/installation
return {
	"saghen/blink.cmp",
	version = "1.*",
	opts = {
		keymap = {
			preset = "super-tab",
			["<C-k>"] = {}, -- free C-k for kitty-navigator
			["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
		},
		completion = {
			documentation = { auto_show = true },
		},
		sources = {
			default = { "lsp", "path", "minuet" },
			providers = {
				minuet = {
					name = "minuet",
					module = "minuet.blink",
					async = true,
					timeout_ms = 3000,
					score_offset = 50,
				},
			},
		},
	},
}
