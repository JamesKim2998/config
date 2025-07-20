return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		vim.filetype.add({
			extension = {
				plist = "xml",
			},
		})
	end,
}
