local mash_app = {"cmd", "alt", "ctrl"}

local app_infos = {
    {'Finder', 'F'},
    {'Fork', 'K'},
    {'Google Chrome', 'C'},
    {'Notes', 'T'},
    {'Notion', 'N'},
    {'Reminders', 'M'},
    {'Rider', 'R'},
    {'WebStorm', 'W'},
}

for i, app_info in ipairs(app_infos) do
    local app_name = app_info[1]
    local app_key = app_info[2]
    hs.hotkey.bind(mash_app, app_key, 'Open ' .. app_name,
        function () hs.application.launchOrFocus(app_name) end)
end

-- Execute open_unity.sh for opening Unity.
hs.hotkey.bind(mash_app, 'U', 'Open Unity', function ()
    hs.execute('bash /Users/jameskim/.hammerspoon/app/open_unity.sh', true)
end)

