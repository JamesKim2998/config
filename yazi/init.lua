require("zoxide"):setup({
	picker = "fzf", -- keep the interactive fzf list (default)
	update_db = true, -- auto-remember every dir you visit
})

-- Hide preview pane by default (toggle with T)
require("toggle-pane"):entry("min-preview")

-- https://github.com/yazi-rs/plugins/tree/main/git.yazi
require("git"):setup()

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

-- Header bar: tabs on left, dimmed bg (#16161e)
local old_header_redraw = Header.redraw
Header.redraw = function(self)
	local elements = old_header_redraw(self)
	local bg_fill = ui.Span(string.rep(" ", self._area.w)):bg("#16161e")
	table.insert(elements, 1, ui.Clear(self._area))
	table.insert(elements, 2, ui.Line(bg_fill):area(self._area))
	return elements
end

-- Custom tabs using theme colors (th.tabs.active / th.tabs.inactive)
Header:children_add(function()
	local nums = { "󰎤", "󰎧", "󰎪", "󰎭", "󰎱", "󰎳", "󰎶", "󰎹", "󰎼" }
	local spans = {}
	for i = 1, #cx.tabs do
		local n = nums[i] or tostring(i)
		local name = tostring(cx.tabs[i].current.cwd):match("([^/]+)/?$") or ""
		local span = ui.Span(" " .. n .. " " .. name .. " ")
		if i == cx.tabs.idx then
			span = span:style(th.tabs.active)
		else
			span = span:style(th.tabs.inactive)
		end
		spans[#spans + 1] = span
	end
	return ui.Line(spans)
end, 100, Header.LEFT)

-- Remove default header cwd
Header:children_remove(1, Header.LEFT)

-- https://github.com/lpnh/fr.yazi - ripgrep search
require("fr"):setup({
	rg = "-i", -- Force case-insensitive search (override --smart-case)
})

-- Remove outer padding only (keep inner padding for dividers)
function Tab:build()
	self._children = {
		Parent:new(self._chunks[1]:pad(ui.Pad.right(1)), self._tab),
		Current:new(self._chunks[2], self._tab),
		Preview:new(self._chunks[3]:pad(ui.Pad.left(1)), self._tab),
		Rail:new(self._chunks, self._tab),
	}
end

-- Status bar: filter on left, file path on right
-- bg: #16161e (darker than main), fg: #565f89 (dimmed)
-- https://github.com/sxyazi/yazi/blob/main/yazi-plugin/preset/components/
function Status:redraw()
	local path = cx.active.current.hovered and tostring(cx.active.current.hovered.url) or ""
	local bg_fill = ui.Span(string.rep(" ", self._area.w)):bg("#16161e")
	local path_span = ui.Span(" " .. path .. " "):fg("#565f89")

	-- Filter indicator on the left (filter is in files.filter)
	local filter = cx.active.current.files.filter
	local filter_span = ui.Span("")
	if filter then
		filter_span = ui.Span(" 󰈲 " .. tostring(filter) .. " "):fg("#7aa2f7")
	end

	return {
		ui.Clear(self._area),
		ui.Line(bg_fill):area(self._area),
		ui.Line(filter_span):area(self._area):align(ui.Align.LEFT),
		ui.Line(path_span):area(self._area):align(ui.Align.RIGHT),
	}
end
