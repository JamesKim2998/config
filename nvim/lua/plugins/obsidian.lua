-- obsidian.nvim: wiki links [[]], note search, backlinks, daily notes
-- UI disabled (render-markdown.nvim handles rendering)
-- Checkbox disabled (markdown-lists.lua handles toggling)
return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	ft = "markdown",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "gf", "<cmd>Obsidian follow_link<cr>", desc = "Follow link", ft = "markdown" },
		{ "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
		{ "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search notes" },
		{ "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks", ft = "markdown" },
		{ "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note", ft = "markdown" },
		{ "<leader>ot", "<cmd>Obsidian template<cr>", desc = "Insert template", ft = "markdown" },
		{ "<leader>ol", "<cmd>Obsidian link<cr>", desc = "Link selection", mode = "v", ft = "markdown" },
		{ "<leader>oe", "<cmd>Obsidian extract_note<cr>", desc = "Extract to note", mode = "v", ft = "markdown" },
	},
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "repo",
				path = function()
					return vim.fs.root(0, ".git") or vim.fn.getcwd()
				end,
			},
		},
		-- Use title as filename (Obsidian default, human-readable)
		note_id_func = function(title)
			if title then
				return title
			end
			return tostring(os.time())
		end,
		frontmatter = { enabled = false },
		picker = { name = "fzf-lua" },
		-- Disable UI (render-markdown.nvim handles rendering)
		ui = { enable = false },
		-- Disable checkbox cycling (markdown-lists.lua handles <leader>tt)
		checkbox = { enabled = false },
	},
}
