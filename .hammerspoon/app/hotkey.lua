local mash_app = {"cmd", "alt", "ctrl"}

local app_infos = {
    {'Google Chrome', 'C'},
    {'Finder', 'F'},
    {'Notion', 'N'},
    {'Notes', 'T'},
    {'Reminders', 'M'},
    {'Rider', 'R'},
    {'Unity', 'U'},
    {'Fork', 'K'},
}

for i, app_info in ipairs(app_infos) do
    local app_name = app_info[1]
    local app_key = app_info[2]
    hs.hotkey.bind(mash_app, app_key, 'Open ' .. app_name,
        function () hs.application.launchOrFocus(app_name) end)
end

