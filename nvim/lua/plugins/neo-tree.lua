-- https://github.com/nvim-neo-tree/neo-tree.nvim

local function find_open()
	local manager = require("neo-tree.sources.manager")
	for _, source in ipairs({ "filesystem", "git_status" }) do
		local winid = manager.get_state(source).winid
		if winid and vim.api.nvim_win_is_valid(winid) then
			return winid, source
		end
	end
end

local function open_last()
	vim.cmd("Neotree " .. (vim.g.neo_tree_last_source or "filesystem"))
end

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	init = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
	end,
	keys = {
		{
			"<C-n>",
			function()
				local winid, source = find_open()
				if not winid then
					open_last()
				elseif vim.api.nvim_get_current_win() == winid then
					vim.g.neo_tree_last_source = source
					vim.cmd("Neotree close")
				else
					vim.api.nvim_set_current_win(winid)
				end
			end,
			desc = "Toggle/Focus Explorer",
		},
		{
			"<leader>e",
			function()
				local winid = find_open()
				if winid then
					vim.api.nvim_set_current_win(winid)
				else
					open_last()
				end
			end,
			desc = "Focus Explorer",
		},
		{ "<leader>gs", "<cmd>Neotree git_status<cr>", desc = "Git Status" },
	},
	opts = {
		close_if_last_window = false,
		enable_git_status = true,
		enable_diagnostics = true,
		open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
		sources = { "filesystem", "git_status" },
		source_selector = {
			winbar = true,
			sources = {
				{ source = "filesystem", display_name = " Files" },
				{ source = "git_status", display_name = " Git" },
			},
		},
		window = {
			position = "left",
			width = 24,
			mappings = {
				["Y"] = {
					function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						vim.fn.setreg("+", path)
						vim.notify("Copied: " .. path)
					end,
					desc = "Copy absolute path",
				},
			},
		},
		filesystem = {
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
				never_show = { ".DS_Store", ".git" },
			},
			follow_current_file = { enabled = true },
			use_libuv_file_watcher = true,
			-- [g / ]g for git navigation are defaults
		},
		-- git_status uses defaults: ga=stage, gu=unstage, gr=revert, gc=commit, gp=push
	},
}
