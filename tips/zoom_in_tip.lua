local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")
local tips_helpers = require("tips.tips_helpers")

local M = {}
local meta = { __index = M }

local TIP_NAME = "zoom_in_tip"

function M.new(playGameScene)
    local zoomInTip = {
        playGameScene = playGameScene
    }
    return setmetatable(zoomInTip, meta)
end

function M:triggerTipOnCondition()
    if not tips_helpers:isSceneValid(self.playGameScene) then
        print("ERROR - invalid play game scene, cannot trigger zoom tip.")
        return false
    end

    local gameModel = self.playGameScene.board.gameModel
    local user = self.playGameScene.creds.user

    if gameModel.player1Turn and user.id ~= gameModel.player1 or
       not gameModel.player1Turn and user.id ~= gameModel.player2 then
        return false  -- Only trigger when it's the current user's turn.
    end

    if not gameModel or type(gameModel.numRows) ~= "number" or gameModel.numRows < 9 then
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
            "Double-tap the board to zoom in!\n\n" ..
            "Double-tap again to zoom back out.",
            nil, onClose)
        tipsModal:show()
        return true
    end

    return false
end


return M
