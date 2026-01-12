local mash_app = { "cmd", "alt", "ctrl" }

local app_infos = {
	{ "Android Studio", "A" },
	{ "Finder", "F" },
	{ "Fork", "K" },
	{ "Google Chrome", "C" },
	{ "Notes", "N" },
	{ "Obsidian", "O" },
	{ "Reminders", "M" },
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
