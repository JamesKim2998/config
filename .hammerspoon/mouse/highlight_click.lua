local fps = 120
local pangSpeed = 120
local fadeDuration = 0.4

local dt = 1 / fps
local fadePerSecond = 1 / fadeDuration

function easeInExpo(t, b, c, d)
    return c * 2^(10 * (t/d - 1)) + b
end

function easeInSin(t, b, c, d)
    return -c * math.cos(t/d * (math.pi/2)) + c + b;
end

function drawCircle(x, y, radius, alpha)
    local circle = hs.drawing.circle(hs.geometry.rect(x-radius, y-radius, radius*2, radius*2))
    circle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=alpha})
    circle:setFill(false)
    circle:setStrokeWidth(5)
    circle:show()
    return circle
end

function animateCirclePangLoop(x, y, radius, alpha)
    if alpha <= 0 then return end
    local alphaEased = 1 - easeInSin(1 - alpha, 0, 1, 1)
    local circle = drawCircle(x, y, radius, alphaEased)
    hs.timer.doAfter(dt, function()
        circle:delete()
        animateCirclePangLoop(x, y, radius + dt * pangSpeed, alpha - dt * fadePerSecond)
    end)
end

function animateCirclePang(x, y)
    animateCirclePangLoop(x, y, 0, 1)
end

function mouseHighlight()
    local mousepoint = hs.mouse.getAbsolutePosition()
    animateCirclePang(mousepoint.x, mousepoint.y)
end

eventtapLeftMouseDown = nil

function registerMouseHighlight()
    if eventtapLeftMouseDown ~= nil then
        return
    end

    eventtapLeftMouseDown = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function(event)
        mouseHighlight()
        return false
    end):start()
end

function unregisterMouseHighlight()
    if eventtapLeftMouseDown == nil then
        return
    end

    eventtapLeftMouseDown:stop()
    eventtapLeftMouseDown = nil
end

function toggleRegisterMouseHighlight()
    if eventtapLeftMouseDown ~= nil then
        unregisterMouseHighlight()
    else
        registerMouseHighlight()
    end
end

hs.hotkey.bind({"cmd","alt","ctrl"}, "M", function()
    hs.notify.new({title="Hammerspoon", informativeText="toggleRegisterMouseHighlight"}):send()
    toggleRegisterMouseHighlight()
end)

