-- https://cmp.saghen.dev/installation
return {
	"saghen/blink.cmp",
	version = "1.*",
	opts = {
		keymap = { preset = "super-tab" },
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
