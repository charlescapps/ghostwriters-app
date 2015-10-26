local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "choose_game_size_and_bonus_words_tip"

function M.new(disableRecordTip, onReleaseButton)
    local chooseGameSizeTip = {
        disableRecordTip = disableRecordTip,
        onReleaseButton = onReleaseButton
    }
    return setmetatable(chooseGameSizeTip, meta)
end

function M:triggerTipOnCondition()
    return self:showTip()
end

function M:showTip()
    if not tips_persist.isTipViewed(TIP_NAME) then
        self:renderTip()
        return true
    end
    return false
end

function M:renderTip()
    local function onClose()
        if not self.disableRecordTip then
            tips_persist.recordViewedTip(TIP_NAME)
        end
    end
    self.tipsModal = tips_modal.new(
        "Tap the grey rectangles to choose the game size and bonus words.",
        nil, onClose,
        "images/choose_game_size_and_bonus_words.jpg", 400, 215, 0, 0, self.onReleaseButton)
    return self.tipsModal:show()
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
