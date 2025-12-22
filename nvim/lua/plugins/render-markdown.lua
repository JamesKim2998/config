-- render-markdown.nvim (visual markdown rendering with icons)
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	ft = { "markdown" },
	opts = {
		heading = {
			icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
		},
		bullet = {
			icons = { "●", "○", "◆", "◇" },
		},
		checkbox = {
			unchecked = { icon = "󰄱 " },
			checked = { icon = "󰄵 " },
		},
		code = {
			sign = false,
			width = "block",
			right_pad = 1,
		},
	},
}
