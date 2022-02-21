local mash_app = {"cmd", "alt", "ctrl"}

local app_infos = {
    {'Finder', 'F'},
    {'Notes', 'N'},
}

for i, app_info in ipairs(app_infos) do
    local app_name = app_info[1]
    local app_key = app_info[2]
    hs.hotkey.bind(mash_app, app_key, '[App] Open ' .. app_name,
        function () hs.application.launchOrFocus(app_name) end)
end

