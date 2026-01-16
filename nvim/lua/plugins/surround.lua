-- https://github.com/kylechui/nvim-surround
-- Add/change/delete surrounding pairs
-- Usage: ys{motion}{char}, ds{char}, cs{old}{new}
-- Examples: ysiw" (surround word with "), ds" (delete "), cs"' (change " to ')
return {
	"kylechui/nvim-surround",
	version = "^3.0.0",
	event = "VeryLazy",
	opts = {},
}
