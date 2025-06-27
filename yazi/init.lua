-- https://github.com/yazi-rs/plugins/tree/main/full-border.yazi
require("full-border"):setup()

require("zoxide"):setup({
	picker = "fzf", -- keep the interactive fzf list (default)
	update_db = true, -- auto-remember every dir you visit
})

-- https://github.com/yazi-rs/plugins/tree/main/git.yazi
require("git"):setup()

-- https://github.com/stelcodes/bunny.yazi
require("bunny"):setup({
	hops = {
		{ key = "~", path = "~", desc = "Home" },
		{ key = "d", path = "~/Downloads", desc = "Downloads" },
		{ key = "c", path = "~/.config", desc = "Config files" },
		-- key and path attributes are required, desc is optional
	},
	desc_strategy = "path", -- If desc isn't present, use "path" or "filename", default is "path"
	ephemeral = true, -- Enable ephemeral hops, default is true
	tabs = true, -- Enable tab hops, default is true
	notify = false, -- Notify after hopping, default is false
	fuzzy_cmd = "fzf", -- Fuzzy searching command, default is "fzf"
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
