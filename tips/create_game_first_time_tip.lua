local shiny_tutorial_widget = require("tutorial.shiny_tutorial_widget")
local tips_persist = require("tips.tips_persist")
local display = require("display")
local common_ui = require("common.common_ui")

local M = {}
local meta = { __index = M }

local TIP_NAME = "create_game_first_time_tip"

function M.new(scene)
    local firstTimeTip = {
        scene = scene
    }
    return setmetatable(firstTimeTip, meta)
end

function M:triggerTipOnCondition()
    if not self.scene then
        return false
    end

    local sceneView = self.scene.view
    if not common_ui.isValidDisplayObj(sceneView) then
        return false
    end

    local createGameButton = self.scene.createGameButton
    if not common_ui.isValidDisplayObj(createGameButton) then
        return false
    end

    return self:showTip(sceneView, createGameButton)
end

function M:showTip(sceneView, createGameButton)
    if not tips_persist.isTipViewed(TIP_NAME) then

        local shiny = shiny_tutorial_widget.new {
            tipText = "Tap to\ncreate a\ndefault game!",
            focusedDisplayObj = createGameButton,
            sceneView = sceneView,
            tipX = display.contentWidth / 2 + 75,
            tipY = display.contentHeight / 2 + 100
        }
        shiny:showTutorial()

        tips_persist.recordViewedTip(TIP_NAME)

        return true
    end

    return false

end


return M
