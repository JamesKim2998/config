-- https://github.com/ibhagwan/fzf-lua
return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "FzfLua",
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
		{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
		{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
		{ "<leader>fw", "<cmd>FzfLua grep_cword<cr>", desc = "Grep word under cursor" },
		{ "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
		{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
		{ "<leader><leader>", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
		{ "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
		{ "<leader>sS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Workspace symbols" },
	},
	opts = function()
		local actions = require("fzf-lua").actions
		return {
			fzf_colors = true, -- inherit colors from nvim colorscheme
			defaults = { git_icons = true, file_icons = true },
			keymap = {
				fzf = {
					["ctrl-q"] = "select-all+accept",
					["ctrl-u"] = "half-page-up",
					["ctrl-d"] = "half-page-down",
				},
			},
			files = {
				actions = {
					["ctrl-y"] = function(selected)
						local path = require("fzf-lua.path").entry_to_file(selected[1]).path -- strip file icon
						vim.fn.setreg("+", path)
						vim.notify("Copied: " .. path)
					end,
					["alt-i"] = { actions.toggle_ignore },
					["alt-h"] = { actions.toggle_hidden },
				},
			},
			grep = {
				actions = {
					["ctrl-y"] = function(selected)
						local path = selected[1]:match("^([^:]+)")
						vim.fn.setreg("+", path)
						vim.notify("Copied: " .. path)
					end,
					["alt-i"] = { actions.toggle_ignore },
					["alt-h"] = { actions.toggle_hidden },
				},
			},
		}
	end,
}
