local mash_app = { "cmd", "alt", "ctrl" }

-- Keyed by bundle ID, not name: a running app can report a different name than its
-- bundle (Visual Studio Code reports as "Code"), which makes hs.application.get miss.
local app_infos = {
	{ "Google Chrome", "C", "com.google.Chrome" },
	{ "Visual Studio Code", "D", "com.microsoft.VSCode" },
	{ "Finder", "F", "com.apple.finder" },
	{ "Fork", "K", "com.DanPristupov.Fork" },
	{ "Notes", "N", "com.apple.Notes" },
	{ "Rider", "R", "com.jetbrains.rider" },
	{ "Slack", "S", "com.tinyspeck.slackmacgap" },
	{ "TexturePacker", "T", "de.code-and-web.TexturePacker" },
	{ "Xcode", "X", "com.apple.dt.Xcode" },
	{ "kitty", "Y", "net.kovidgoyal.kitty" },
}

-- Sort by window id: allWindows() is ordered front-to-back, so cycling by that order
-- would swap the top two windows forever instead of walking the whole set.
local function focus_next_window(app)
	local wins = {}
	for _, w in ipairs(app:allWindows()) do
		if w:isStandard() and w:isVisible() then
			wins[#wins + 1] = w
		end
	end
	if #wins < 2 then
		return
	end
	table.sort(wins, function(a, b)
		return a:id() < b:id()
	end)

	local focused = hs.window.focusedWindow()
	local current = 0
	for i, w in ipairs(wins) do
		if focused and w:id() == focused:id() then
			current = i
		end
	end
	wins[current % #wins + 1]:focus()
end

for _, app_info in ipairs(app_infos) do
	local app_name = app_info[1]
	local app_key = app_info[2]
	local bundle_id = app_info[3]
	hs.hotkey.bind(mash_app, app_key, "Open " .. app_name, function()
		local app = hs.application.get(bundle_id)
		if app and app:isFrontmost() then
			focus_next_window(app)
		else
			hs.application.launchOrFocusByBundleID(bundle_id)
		end
	end)
end

-- Open / focus the meow-tower Unity editor via studio-boxcat/unity-launcher.
hs.hotkey.bind(mash_app, "U", "Open Unity", function()
	hs.execute("/Users/jameskim/Develop/meow-tower/!meow.app/Contents/MacOS/unity-launcher", true)
end)
