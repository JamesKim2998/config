require("zoxide"):setup({
	picker = "fzf", -- keep the interactive fzf list (default)
	update_db = true, -- auto-remember every dir you visit
})

-- Hide preview pane by default (toggle with T)
require("toggle-pane"):entry("min-preview")

-- https://github.com/yazi-rs/plugins/tree/main/git.yazi
require("git"):setup()

-- Soft filter — dim non-matches instead of hiding (`/`). See plugin header.
require("soft-filter"):setup()

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
		if utf8.len(name) and utf8.len(name) > 12 then
			name = name:sub(1, utf8.offset(name, 13) - 1) .. "…"
		end
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

-- Repo + worktree (branch) indicator for the status bar. Lives as a plugin
-- because `ps.sub`/`ya.sync` must be called in plugin context. See
-- [[git-status.yazi/main.lua]] for the sync/async wiring.
local git_status = require("git-status")
git_status:setup()

-- Status bar: filter + git context on left, file path on right
-- bg: #16161e (darker than main), fg: #565f89 (dimmed)
-- https://github.com/sxyazi/yazi/blob/main/yazi-plugin/preset/components/
function Status:redraw()
	local bg_fill = ui.Span(string.rep(" ", self._area.w)):bg("#16161e")

	-- Soft-filter indicator on the left (we replaced yazi's built-in filter).
	-- Per-dir scoped — show the filter belonging to the active dir.
	local soft = require("soft-filter").current_filter()
	local filter_span = ui.Span("")
	if soft and soft ~= "" then
		filter_span = ui.Span(" 󰈲 " .. soft .. " "):fg("#7aa2f7")
	end

	-- Repo · branch (only when inside a git working tree). Read from the
	-- cache populated by the `cd` subscription in `git-status.yazi`.
	local g = git_status.get(tostring(cx.active.current.cwd))
	local left = { filter_span }
	if g.repo ~= "" then
		left[#left + 1] = ui.Span(" 󰊢 " .. g.repo):fg("#98bb6c")
		if g.branch ~= "" then
			left[#left + 1] = ui.Span("  " .. g.branch):fg("#98bb6c")
		end
		left[#left + 1] = ui.Span(" ")
	end

	-- Hovered path on the right. Show repo-relative when inside a git
	-- worktree (much shorter than absolute, and the left side already
	-- identifies the repo). Otherwise fall back to the absolute path.
	local hovered = cx.active.current.hovered and tostring(cx.active.current.hovered.url) or ""
	local rel = hovered
	if g.toplevel ~= "" and hovered ~= "" then
		if hovered == g.toplevel then
			rel = "."
		elseif hovered:sub(1, #g.toplevel + 1) == g.toplevel .. "/" then
			rel = hovered:sub(#g.toplevel + 2)
		end
	end
	local path_span = ui.Span(" " .. rel .. " "):fg("#565f89")

	-- Order matters: yazi paints in sequence, so the last element wins on
	-- overlap. Left content (repo · branch · filter) takes priority over
	-- the path on narrow widths — render it last to clip the path tail.
	return {
		ui.Clear(self._area),
		ui.Line(bg_fill):area(self._area),
		ui.Line(path_span):area(self._area):align(ui.Align.RIGHT),
		ui.Line(left):area(self._area):align(ui.Align.LEFT),
	}
end
