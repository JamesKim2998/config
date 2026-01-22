-- https://github.com/nvim-neo-tree/neo-tree.nvim
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
				local manager = require("neo-tree.sources.manager")
				local state = manager.get_state("filesystem")
				local git_state = manager.get_state("git_status")
				local fs_open = state.winid and vim.api.nvim_win_is_valid(state.winid)
				local git_open = git_state.winid and vim.api.nvim_win_is_valid(git_state.winid)

				if fs_open or git_open then
					vim.g.neo_tree_last_source = git_open and "git_status" or "filesystem"
					vim.cmd("Neotree close")
				else
					local source = vim.g.neo_tree_last_source or "filesystem"
					vim.cmd("Neotree " .. source)
				end
			end,
			desc = "Toggle Explorer",
		},
		{
			"<leader>e",
			function()
				local manager = require("neo-tree.sources.manager")
				local state = manager.get_state("filesystem")
				local git_state = manager.get_state("git_status")
				local fs_open = state.winid and vim.api.nvim_win_is_valid(state.winid)
				local git_open = git_state.winid and vim.api.nvim_win_is_valid(git_state.winid)

				if fs_open or git_open then
					-- Just focus the existing window
					local winid = git_open and git_state.winid or state.winid
					vim.api.nvim_set_current_win(winid)
				else
					-- Open with last source
					local source = vim.g.neo_tree_last_source or "filesystem"
					vim.cmd("Neotree " .. source)
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
