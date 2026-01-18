-- render-markdown.nvim: visual rendering (headings, bullets, checkboxes, code blocks)
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
	opts = {
		heading = {
			sign = false,
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
