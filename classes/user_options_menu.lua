local common_ui = require("common.common_ui")
local display = require("display")
local transition = require("transition")


local M = {}
local meta = { __index = M }

local BOOK_POPUP_WIDTH = 750
local BOOK_POPUP_HEIGHT = 1024

function M.new()
    local userOptionsMenu = {}
    return setmetatable(userOptionsMenu, meta)
end

function M:render()
    self.view = display.newGroup()
    self.view.alpha = 0

    self.screen = self:drawScreen()
    self.background = self:drawBackground()

    self.view:insert(self.screen)
    self.view:insert(self.background)

    return self.view
end

function M:show()
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end

    transition.fadeIn(self.view, { time = 1000 })
end

function M:destroy()
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end

    local function onComplete()
        common_ui.safeRemove(self.view)
    end

    transition.fadeOut(self.view, { time = 800, onComplete = onComplete, onCancel = onComplete })
end

function M:drawScreen()
    local screen = common_ui.drawScreen()

    local function onTouch(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            self:destroy()
        elseif event.phase == "cancelled" then
           display.getCurrentStage():setFocus(nil)
        end
        return true
    end

    local function onTap(event)
        return true
    end

    screen:addEventListener("touch", onTouch)
    screen:addEventListener("tap", onTap)

    return screen
end

function M:drawBackground()
    local background = display.newImageRect("images/book_popup.jpg", BOOK_POPUP_WIDTH, BOOK_POPUP_HEIGHT)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local function onTouch(event)
        return true
    end

    local function onTap(event)
        return true
    end

    background:addEventListener("touch", onTouch)
    background:addEventListener("tap", onTap)

    return background
end

return M

