--- Copy path / dirname with $HOME collapsed to `~`.
--- Args: "path" or "dirname". Mirrors yazi's built-in `copy path`/
--- `copy dirname` (selection if any, else hovered; newline-joined), then
--- pipes through pbcopy.

local selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, u in pairs(tab.selected) do
		paths[#paths + 1] = tostring(u)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths
end)

local function tildify(p, home)
	if home == "" then return p end
	if p == home then return "~" end
	if p:sub(1, #home + 1) == home .. "/" then return "~/" .. p:sub(#home + 2) end
	return p
end

local function dirname(p)
	return p:match("^(.*)/[^/]+$") or p
end

return {
	entry = function(_, job)
		local mode = job.args[1]
		local urls = selected_or_hovered()
		if #urls == 0 then
			return ya.notify({ title = "copy-path", content = "No file selected", level = "warn", timeout = 3 })
		end

		local home = os.getenv("HOME") or ""
		local lines = {}
		for _, p in ipairs(urls) do
			if mode == "dirname" then p = dirname(p) end
			lines[#lines + 1] = tildify(p, home)
		end
		local text = table.concat(lines, "\n")

		local child, err = Command("pbcopy"):stdin(Command.PIPED):spawn()
		if not child then
			return ya.notify({ title = "copy-path", content = "pbcopy spawn failed: " .. tostring(err), level = "error", timeout = 5 })
		end
		child:write_all(text)
		child:flush()
		child:wait()
	end,
}
