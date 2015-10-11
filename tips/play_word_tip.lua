local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")
local tips_helpers = require("tips.tips_helpers")

local M = {}
local meta = { __index = M }

local TIP_NAME = "play_word_tip"

function M.new(playGameScene)
    local zoomInTip = {
        playGameScene = playGameScene
    }
    return setmetatable(zoomInTip, meta)
end

function M:triggerTipOnCondition()
    if not tips_helpers:isSceneValid(self.playGameScene) then
        print("ERROR - invalid play game scene, cannot trigger play word.")
        return false
    end

    local gameModel = self.playGameScene.board.gameModel
    local user = self.playGameScene.creds.user
    local rack = self.playGameScene.rack

    if gameModel.player1Turn and user.id ~= gameModel.player1 or 
       not gameModel.player1Turn and user.id ~= gameModel.player2 then
        return false  -- Only trigger when it's the current user's turn.
    end

    if not rack or type(rack.tileImages) ~= "table" or #rack.tileImages <= 0 then
        return false -- only trigger if the user has tiles.
    end

    -- Only trigger the tip if it's the 2nd turn for the user.
    if gameModel.player1 == user.id and gameModel.moveNum == 3 or
       gameModel.player2 == user.id and gameModel.moveNum == 4 then
        return self:showTip()
    else
        return false
    end
end

function M:showTip()
    if not tips_persist.isTipViewed(TIP_NAME) then
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        local tipsModal = tips_modal.new(
            "To play a word, drag tiles from your hand to the board.\n\n" ..
            "Then press the Play button, and reap in the points!\n\n" ..
            "Try to place high-scoring letters on bonus squares.",
            nil, onClose)
        tipsModal:show()
        return true
    end

    return false
end


return M
