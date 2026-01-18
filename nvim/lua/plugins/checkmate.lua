-- checkmate.nvim: checkbox rendering ([ ] → □, [x] → ✔)
-- List continuation handled by markdown-lists.lua
return {
	"bngarren/checkmate.nvim",
	ft = "markdown",
	opts = {
		list_continuation = { enabled = false },
	},
}
