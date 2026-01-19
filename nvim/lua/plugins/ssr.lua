-- ssr.nvim: Treesitter structural search and replace
-- Use $name wildcards to match any AST node
return {
	"cshuaimin/ssr.nvim",
	keys = {
		{ "<leader>sr", function() require("ssr").open() end, mode = { "n", "x" }, desc = "Structural Replace" },
	},
}
