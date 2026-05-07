--- Soft filter — dim non-matching files instead of hiding (`/`).
--- Type-to-jump (vim-style) while the prompt is open; `n`/`N` walk matches
--- afterwards. Match-first reorder isn't implemented — see [[TODO.md]].
--- Pattern: `Entity.style` override (cf. https://github.com/sxyazi/yazi/discussions/2419).

-- ya.sync's `st` IS the plugin module table (yazi-plugin/src/utils/sync.rs:50
-- pushes `LOADER.try_load(&current)` as the first arg), so writes to
-- `st.filter` are visible to `M.filter` reads from render-context code such
-- as Entity.style and init.lua's Status:redraw.
local M = { filter = "" }

local function name_matches(file, needle)
	local name = file.name
	return name and name:lower():find(needle:lower(), 1, true) ~= nil
end

local function find_match(files, from, to, step, needle)
	for i = from, to, step do
		if name_matches(files[i], needle) then
			return i
		end
	end
end

-- Apply filter and (vim-style incremental) jump to the next match. Stays put
-- if cursor is already on a match; wraps from the top if no forward match.
-- Returns an `arrow` delta or nil. Single round-trip to main thread.
local apply_filter = ya.sync(function(st, value)
	st.filter = value or ""
	ui.render()
	if st.filter == "" then
		return nil
	end
	local cur = cx.active.current
	if not cur or not cur.hovered then
		return nil
	end
	if name_matches(cur.hovered, st.filter) then
		return nil
	end
	local files = cur.files
	local n = #files
	local cursor_idx = cur.cursor + 1 -- cur.cursor is 0-indexed; cf. tasks.lua:34
	local target = find_match(files, cursor_idx + 1, n, 1, st.filter)
		or find_match(files, 1, cursor_idx - 1, 1, st.filter)
	if target then
		return target - cursor_idx
	end
end)

-- Walk to next/prev match, always moving (unlike apply_filter, which stays
-- put if already on a match). Wraps around like vim's `n` with `wrapscan`.
local jump_delta = ya.sync(function(st, dir)
	local f = st.filter or ""
	if f == "" then
		return nil
	end
	local cur = cx.active.current
	if not cur or not cur.hovered then
		return nil
	end
	local files = cur.files
	local n = #files
	local cursor_idx = cur.cursor + 1
	local target
	if dir == "next" then
		target = find_match(files, cursor_idx + 1, n, 1, f)
			or find_match(files, 1, cursor_idx - 1, 1, f)
	else
		target = find_match(files, cursor_idx - 1, 1, -1, f)
			or find_match(files, n, cursor_idx + 1, -1, f)
	end
	if target then
		return target - cursor_idx
	end
end)

local clear_filter = ya.sync(function(st)
	st.filter = ""
	ui.render()
end)

function M:setup()
	local orig_style = Entity.style
	Entity.style = function(self)
		local s = orig_style(self)
		local f = M.filter
		if f == "" or not self._file.in_current then
			return s
		end
		if name_matches(self._file, f) then
			return s
		end
		return s:patch(ui.Style():dim())
	end
end

function M:entry(job)
	local action = job and job.args and job.args[1]

	if action == "next" or action == "prev" then
		local delta = jump_delta(action)
		if delta then
			ya.emit("arrow", { delta })
		end
		return
	end

	if action == "clear" then
		clear_filter()
		-- Dispatch the `escape` action by name; this bypasses the keymap layer
		-- (no recursion into our own Esc binding).
		ya.emit("escape", {})
		return
	end

	-- Default: open a fresh prompt. (We deliberately don't pre-fill with the
	-- existing filter — `/` always starts blank; existing filter is cleared.)
	clear_filter()
	local input = ya.input {
		title = "Soft filter:",
		pos = { "center", w = 50 },
		realtime = true,
		debounce = 0.05,
	}
	while true do
		local value, event = input:recv()
		if event == 3 then
			local delta = apply_filter(value or "")
			if delta then
				ya.emit("arrow", { delta })
			end
		elseif event == 1 then
			break -- Enter: keep filter active
		else
			clear_filter() -- Esc / other
			break
		end
	end
end

return M
