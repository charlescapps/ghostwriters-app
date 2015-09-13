local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "zoom_in_tip"

function M.new(gameModel)
    local zoomInTip = {
        gameModel = gameModel
    }
    return setmetatable(zoomInTip, meta)
end

function M:triggerTipOnCondition()
    local gameModel = self.gameModel

    if type(gameModel) ~= "table" then
        return false
    end

    if type(gameModel.numRows) ~= "number" or gameModel.numRows < 9 then
        return false
    end

    return self:showTip()
end

function M:showTip()
    if not tips_persist.isTipViewed(TIP_NAME) then
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        local tipsModal = tips_modal.new(
            "Double-tap an empty square to zoom in!\n\n" ..
            "When zoomed, You can grab tiles and play words.\n\n" ..
            "The zoomed area will scroll as you grab tiles.",
            nil, onClose)
        tipsModal:show()
        return true
    end

    return false
end


return M
