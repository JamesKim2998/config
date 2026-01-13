local mash_app = { "cmd", "alt", "ctrl" }

local app_infos = {
	{ "Android Studio", "A" },
	{ "Finder", "F" },
	{ "Fork", "K" },
	{ "Google Chrome", "C" },
	{ "Notes", "N" },
	{ "Obsidian", "O" },
	{ "Rider", "R" },
	{ "Slack", "S" },
	{ "WebStorm", "W" },
	{ "Xcode", "X" },
	{ "kitty", "Y" },
	{ "TexturePacker", "T" },
	{ "Visual Studio Code", "V" },
}

for i, app_info in ipairs(app_infos) do
	local app_name = app_info[1]
	local app_key = app_info[2]
	hs.hotkey.bind(mash_app, app_key, "Open " .. app_name, function()
		hs.application.launchOrFocus(app_name)
	end)
end

-- Execute open_unity.sh for opening Unity.
hs.hotkey.bind(mash_app, "U", "Open Unity", function()
	hs.execute("/Users/jameskim/Develop/meow-tower/!meow.app/Contents/MacOS/UnityLauncher", true)
end)

-- Warp mouse to center of focused window (no mode required)
hs.hotkey.bind(mash_app, "P", function()
	local win = hs.window.focusedWindow()
	if win then
		local f = win:frame()
		hs.mouse.absolutePosition({ x = f.x + f.w / 2, y = f.y + f.h / 2 })
	end
end)

-- Vimouse: Cmd+Opt+Ctrl+; to toggle mouse mode
local vimouse = require("vimouse")
vimouse(mash_app, ";")
