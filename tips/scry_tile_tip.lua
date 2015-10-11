local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")
local tips_helpers = require("tips.tips_helpers")

local M = {}
local meta = { __index = M }

local TIP_NAME = "scry_tile_tip"

function M.new(playGameScene)
    local scryTileTip = {
        playGameScene = playGameScene
    }
    return setmetatable(scryTileTip, meta)
end

function M:triggerTipOnCondition()
    if not tips_helpers:isSceneValid(self.playGameScene) then
        print("ERROR - invalid play game scene, cannot trigger scry tile tip.")
        return false
    end

    local gameModel = self.playGameScene.board.gameModel
    local user = self.playGameScene.creds.user

    if gameModel.player1Rack:find("^", 1, true) and gameModel.player1Turn and gameModel.player1 == user.id or
       gameModel.player2Rack:find("^", 1, true) and not gameModel.player1Turn and gameModel.player2 == user.id then
        print("Triggering scry tile tip b/c current player has a scry tile.")
        return self:showTip()
    end

    return false
end

function M:showTip()
    if not tips_persist.isTipViewed(TIP_NAME) then
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        local tipsModal = tips_modal.new("Drag Oracle tiles from your hand to the board to reveal a powerful word.", nil, onClose,
            "images/scry_tip.png", 250, 250, 0, 0)
        tipsModal:show()
        return true
    end
    return false
end

return M
