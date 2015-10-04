local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "free_question_tile_tip"

function M.new(playGameScene)
    local freeQuestionTileTip = {
        playGameScene = playGameScene
    }
    return setmetatable(freeQuestionTileTip, meta)
end

function M:triggerTipOnCondition()
    if not self:isSceneValid(self.playGameScene) then
        print("ERROR - invalid play game scene, cannot trigger free question tile tip.")
        return false
    end

    local gameModel = self.playGameScene.board.gameModel
    local user = self.playGameScene.creds.user

    if not gameModel.player1Turn and
           gameModel.player2 == user.id and
           gameModel.moveNum == 2 then
        print("Triggering free question tile tip b/c it is turn 2 and current player is player 2.")
        return self:showTip()
    end

    return false
end

function M:showTip()
    if not tips_persist.isTipViewed(TIP_NAME) then
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        local tipsModal = tips_modal.new("You accepted a challenge, so you get a free question tile. Use it wisely!", nil, onClose,
            "images/question_tip.png", 250, 250, 0, 0)
        tipsModal:show()
        return true
    end
    return false
end

function M:isSceneValid(playGameScene)
   return playGameScene and self:isBoardValid(playGameScene.board) and
          playGameScene.creds and playGameScene.creds.user and playGameScene.creds.user.id and true
end

function M:isBoardValid(board)
    return board and board.tileImages and board.tilesGroup and self:isGameModelValid(board.gameModel)
end

function M:isGameModelValid(gameModel)
    return gameModel and gameModel.moveNum and gameModel.player1Rack and gameModel.player2Rack and gameModel.player1 and gameModel.player2 and true
end


return M
