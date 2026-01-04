return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			disabled_filetypes = { statusline = { "neo-tree" } },
			section_separators = "",
			component_separators = "",
		},
		sections = {
			lualine_a = {
				{
					"mode",
					fmt = function(s)
						local icons = {
							NORMAL = "󰆾",
							INSERT = "󰏫",
							VISUAL = "󰒉",
							["V-LINE"] = "󰒉",
							["V-BLOCK"] = "󰒉",
							REPLACE = "󰛔",
							COMMAND = "󰘳",
							TERMINAL = "󰆍",
						}
						return icons[s] or s
					end,
				},
			},
			lualine_c = {},
			lualine_x = {},
		},
	},
}
