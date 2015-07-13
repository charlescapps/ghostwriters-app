local common_ui = require("common.common_ui")
local nav = require("common.nav")

local display = require("display")
local transition = require("transition")
local widget = require("widget")

local M = {}
local meta = { __index = M }

function M.new(parentScene)
    local backToMainMenuPopup = {
        parentScene = parentScene
    }

    return setmetatable(backToMainMenuPopup, meta)
end

function M:render()
    self.view = display.newGroup()
    self.view.alpha = 0

    self.screen = self:drawScreen()
    self.button = self:drawBackToMainMenuButton()

    self.view:insert(self.screen)
    self.view:insert(self.button)

    return self.view
end

function M:show()
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end

    transition.fadeIn(self.view, { time = 1000 })
end

function M:drawBackToMainMenuButton()

    local function onRelease()
        if self.button then
            self.button:setEnabled(false)

        end

        nav.goToSceneFrom(self.parentScene and self.parentScene.sceneName, "scenes.title_scene", "fade")
        self:destroy()
        return true
    end

    local button = widget.newButton {
        x = display.contentCenterX,
        y = display.contentCenterY,
        defaultFile = "images/back_to_main_menu_default.png",
        overFile = "images/back_to_main_menu_over.png",
        onRelease = onRelease
    }

    return button
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
        if event.numTaps == 1 then
           self:destroy()
        end
        return true
    end

    screen:addEventListener("touch", onTouch)
    screen:addEventListener("tap", onTap)

    return screen
end

function M:destroy()
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end

    local function onComplete()
        common_ui.safeRemove(self.view)
    end

    transition.cancel(self.view)
    transition.fadeOut(self.view, { time = 1000, onComplete = onComplete, onCancel = onComplete })
end

return M

