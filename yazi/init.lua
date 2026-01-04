require("zoxide"):setup({
	picker = "fzf", -- keep the interactive fzf list (default)
	update_db = true, -- auto-remember every dir you visit
})

-- Hide preview pane by default (toggle with T)
require("toggle-pane"):entry("min-preview")

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

-- Custom tab bar on left side of header (hide default tabs)
function Tabs.height() return 0 end

Header:children_add(function()
	local nums = { "󰎤", "󰎧", "󰎪", "󰎭", "󰎱", "󰎳", "󰎶", "󰎹", "󰎼" }
	local spans = {}
	for i = 1, #cx.tabs do
		local n = nums[i] or tostring(i)
		local name = tostring(cx.tabs[i].current.cwd):match("([^/]+)/?$") or ""
		local span = ui.Span(" " .. n .. " " .. name .. " ")
		if i == cx.tabs.idx then
			span = span:reverse()
		end
		spans[#spans + 1] = span
	end
	return ui.Line(spans)
end, 100, Header.LEFT)

-- Remove default header cwd
Header:children_remove(1, Header.LEFT)

-- Status bar: file path only (right-aligned)
function Status:redraw()
	local path = cx.active.current.hovered and tostring(cx.active.current.hovered.url) or ""
	return {
		ui.Line(ui.Span(" " .. path .. " ")):area(self._area):align(ui.Align.RIGHT),
	}
end
