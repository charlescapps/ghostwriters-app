local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "currency_tip"

function M.new(disableRecordTip, onReleaseButton)
    local currencyTip = {
        disableRecordTip = disableRecordTip,
        onReleaseButton = onReleaseButton
    }
    return setmetatable(currencyTip, meta)
end

function M:triggerTipOnCondition()
   -- Trivial condition, always true
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
        "You get 1 free book per hour for games and tiles.\nTap the bookshelf to buy extra books or infinite books.",
        nil, onClose, "images/currency_tip.jpg", 375, 148, 0, 30, self.onReleaseButton)
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
