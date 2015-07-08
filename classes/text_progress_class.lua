local display = require("display")
local transition = require("transition")

local text_progress_class = {}
local text_progress_class_mt = { __index = text_progress_class }

function text_progress_class.new(sceneViewGroup, x, y, text, fontSize, alpha)
    local displayGroup = display.newGroup()
    displayGroup.alpha = 0

    local textProgress = {
        sceneViewGroup = sceneViewGroup,
        text = text,
        fontSize = fontSize,
        alpha = alpha,
        displayGroup = displayGroup
    }

    textProgress = setmetatable(textProgress, text_progress_class_mt)
    local screen = textProgress:createScreen(alpha)
    local textObj = textProgress:createTextObj(x, y, text, fontSize)
    textProgress.screen, textProgress.textObj = screen, textObj
    displayGroup:insert(screen)
    displayGroup:insert(textObj)
    sceneViewGroup:insert(displayGroup)
    return textProgress
end

function text_progress_class:start()
    self.displayGroup:toFront()
    transition.fadeIn(self.displayGroup, { time = 500 })
end

function text_progress_class:stop(onComplete)
    print("Stopping progress text...")
    transition.cancel(self.displayGroup)
    local function onFadeOutComplete()
        if self.displayGroup and self.displayGroup.removeSelf then
            self.displayGroup:removeSelf()
        end
        if onComplete then
            onComplete()
        end
    end
    transition.fadeOut(self.displayGroup, { time = 250, onComplete = onFadeOutComplete, onCancel = onFadeOutComplete })
end

function text_progress_class:createTextObj(x, y, text, fontSize, alpha)
    return display.newText {
        x = x,
        y = y,
        text = text,
        font = native.systemFont,
        fontSize = fontSize or 40,
        align = "center"
    }
end

function text_progress_class:createScreen(alpha)
    local screen = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    screen:setFillColor(0, 0, 0)
    screen.alpha = alpha or 0.3
    local x, y = display.contentWidth / 2, display.contentHeight / 2
    screen.x, screen.y = x, y

    screen:addEventListener("touch", function(event)
        return true
    end)

    return screen
end


return text_progress_class

