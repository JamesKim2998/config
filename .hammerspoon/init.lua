require 'app.hotkey'
require 'mouse.highlight_click'

hsreload_keys = hsreload_keys or {{"cmd", "alt", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "[Global] Reload Configuration", function() hs.reload() end)
end
