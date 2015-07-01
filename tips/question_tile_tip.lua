local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "question_tile_tip"

function M.new(playGameScene)
    local questionTileTip = {
        playGameScene = playGameScene
    }
    return setmetatable(questionTileTip, meta)
end

function M:triggerTipOnCondition()
    if not self:isSceneValid(self.playGameScene) then
        print("ERROR - invalid play game scene, cannot trigger scry tile tip.")
        return
    end

    local gameModel = self.playGameScene.board.gameModel
    local user = self.playGameScene.creds.user

    if gameModel.player1Rack:find("*", 1, true) and gameModel.player1Turn and gameModel.player1 == user.id or
       gameModel.player2Rack:find("*", 1, true) and not gameModel.player1Turn and gameModel.player2 == user.id then
        print("Triggering question tile tip b/c current player has a question tile.")
        self:showTip()
    end
end

function M:showTip()
    local board = self.playGameScene.board
    if not tips_persist.isTipViewed(TIP_NAME) then
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        local tipsModal = tips_modal.new(
            "Drag a question tile to the board, then you can select a letter.\n\n" ..
            "A question tile is worth the full points of the chosen letter.",
            nil, onClose)
        tipsModal:show()
    end

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