-- https://github.com/folke/flash.nvim
-- Fast navigation with search labels
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
		{ "S", mode = { "n", "x", "o" }, function() require("flash").jump({ search = { forward = false } }) end, desc = "Flash Backward" },
		{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
		{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
	},
}
