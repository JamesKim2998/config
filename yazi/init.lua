require("zoxide"):setup({
	picker = "fzf", -- keep the interactive fzf list (default)
	update_db = true, -- auto-remember every dir you visit
})

-- https://github.com/yazi-rs/plugins/tree/main/git.yazi
require("git"):setup()

-- https://github.com/stelcodes/bunny.yazi
require("bunny"):setup({
	hops = {
		{ key = "d", path = "~/Develop", desc = "Develop" },
		{ key = "c", path = "~/Develop/config", desc = "Config" },
		{ key = "1", path = "~/Develop/meow-tower", desc = "Meow Tower" },
		{ key = "a", path = "~/Develop/meow-assets", desc = "Meow Assets" },
		{ key = "t", path = "~/Develop/meow-toolbox", desc = "Meow Toolbox" },
		{ key = "l", path = "~/Develop/meow-toolbox/assets/langpack", desc = "Meow Langpack" },
		{ key = "m", path = "~/Develop/meow-toolbox/assets/dev-media", desc = "Meow Dev Media" },
	},
	desc_strategy = "path", -- If desc isn't present, use "path" or "filename", default is "path"
	notify = false, -- Notify after hopping, default is false
})

-- https://github.com/yazi-rs/plugins/tree/main/mactag.yazi
require("mactag"):setup({
	-- Keys used to add or remove tags
	keys = {
		r = "Red",
		o = "Orange",
		y = "Yellow",
		g = "Green",
		b = "Blue",
		p = "Purple",
	},
	-- Colors used to display tags
	colors = {
		Red = "#ee7b70",
		Orange = "#f5bd5c",
		Yellow = "#fbe764",
		Green = "#91fc87",
		Blue = "#5fa3f8",
		Purple = "#cb88f8",
	},
})

-- https://github.com/Rolv-Apneseth/starship.yazi
require("starship"):setup()
