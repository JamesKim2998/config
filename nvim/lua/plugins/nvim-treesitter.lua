return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	lazy = false,
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"lua",
			"markdown",
			"markdown_inline",
			"regex",
			"vim",
			"vimdoc",
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)

		-- Custom filetype mappings
		vim.filetype.add({
			extension = {
				plist = "xml",
			},
		})

		-- Enable treesitter highlighting for all filetypes
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
			end,
		})
	end,
}
