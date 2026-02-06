-- https://github.com/milanglacier/minuet-ai.nvim
return {
	{
		"milanglacier/minuet-ai.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("minuet").setup({
				provider = "gemini",
				n_completions = 1,
				throttle = 500,
				debounce = 200,
				virtualtext = {
					auto_trigger_ft = { "*" },
					keymap = {
						accept = "<A-A>",
						accept_line = "<A-a>",
						prev = "<A-[>",
						next = "<A-]>",
						dismiss = "<A-e>",
					},
				},
				provider_options = {
					gemini = {
						model = "gemini-3-flash-preview",
						optional = {
							generationConfig = {
								maxOutputTokens = 256,
								thinkingConfig = { thinkingBudget = 0 }, -- disable thinking to avoid streaming timeout
							},
						},
					},
				},
			})
		end,
	},
	-- Extend blink.cmp keymap (merged with spec in blink-cmp.lua)
	{
		"saghen/blink.cmp",
		dependencies = { "milanglacier/minuet-ai.nvim" },
		opts = function(_, opts)
			opts.keymap = opts.keymap or {}
			opts.keymap["<A-y>"] = require("minuet").make_blink_map()
		end,
	},
}
