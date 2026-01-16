-- https://github.com/ibhagwan/fzf-lua
return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- File icons in picker
	event = "VeryLazy", -- Load after startup for faster init
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
		{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
		{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
		{ "<leader>fw", "<cmd>FzfLua grep_cword<cr>", desc = "Grep word under cursor" },
		-- diagnostics/symbols moved to trouble.nvim
		{ "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
		{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
		{ "<leader><leader>", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
	},
	opts = {
		defaults = {
			git_icons = true,
			file_icons = true,
		},
		keymap = {
			fzf = {
				["ctrl-q"] = "select-all+accept", -- send all to quickfix
				["ctrl-u"] = "half-page-up",
				["ctrl-d"] = "half-page-down",
			},
		},
		files = {
			actions = {
				["ctrl-y"] = function(selected)
					vim.fn.setreg("+", selected[1])
					vim.notify("Copied: " .. selected[1])
				end,
				["alt-i"] = { require("fzf-lua").actions.toggle_ignore },
				["alt-h"] = { require("fzf-lua").actions.toggle_hidden },
			},
		},
		grep = {
			actions = {
				["ctrl-y"] = function(selected)
					local path = selected[1]:match("^([^:]+)")
					vim.fn.setreg("+", path)
					vim.notify("Copied: " .. path)
				end,
				["alt-i"] = { require("fzf-lua").actions.toggle_ignore },
				["alt-h"] = { require("fzf-lua").actions.toggle_hidden },
			},
		},
	},
}
