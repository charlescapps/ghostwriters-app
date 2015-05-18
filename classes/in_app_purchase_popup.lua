local display = require("display")
local transition = require("transition")

local M = {}
local meta = { __index = M }

function M.new()
    local popup = {
    }
    print("Creating new in-app purchase popup")
    return setmetatable(popup, meta)
end

function M:render()
    print("Rendering in-app purchase pop-up")
    self.view = display.newGroup()
    self.view.alpha = 0

    self.screen = self:drawScreen()
    self.background = self:drawBackground()

    self.view:insert(self.screen)
    self.view:insert(self.background)
    return self.view
end

function M:drawBackground()
    local bg = display.newImageRect("images/purchase_modal_bg.png", 750, 900)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    return bg
end

function M:drawScreen()
    local screen = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    screen:setFillColor(0, 0, 0, 0.5)
    local popup = self

    screen:addEventListener("touch", function(event)
        if event.phase == "began" then
           display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            popup:destroy()
        elseif event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end)

    screen:addEventListener("tap", function(event)
        return true
    end)

    return screen
end

function M:show()
    transition.fadeIn(self.view, { time = 1000 })
end

function M:destroy()
    local function onComplete()
        if self.view and self.view.removeSelf then
            self.view:removeSelf()
        end
    end

    transition.fadeOut(self.view, {
        time = 700,
        onComplete = onComplete,
        onCancel = onComplete
    })
end


return M

