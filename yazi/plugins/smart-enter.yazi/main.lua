--- @since 25.5.31
--- @sync entry
--- https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi

local blacklist = {
	".DS_Store",
}

local function setup(self, opts) self.open_multi = opts.open_multi end

local function is_blacklisted(name)
	for _, v in ipairs(blacklist) do
		if name == v then return true end
	end
	return false
end

local function entry(self)
	local h = cx.active.current.hovered
	if not h then return end
	if h.cha.is_dir then
		ya.emit("enter", {})
	elseif is_blacklisted(h.name) then
		ya.notify { title = "smart-enter", content = "Skipping " .. h.name, level = "warn", timeout = 2 }
	else
		ya.emit("open", { hovered = not self.open_multi })
	end
end

return { entry = entry, setup = setup }
