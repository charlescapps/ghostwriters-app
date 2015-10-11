local display = require("display")
local widget = require("widget")
local tips_modal = require("tips.tips_modal")

local M = {}

function M.drawTipButton(tipText, width, height, onClose)
    local function onRelease()
        local tipsModal = tips_modal.new(tipText, nil, onClose)
        tipsModal:show()
    end

    return widget.newButton {
        width = width or 100,
        height = height or 100,
        defaultFile = "images/question_button_default.png",
        overFile = "images/question_button_over.png",
        onRelease = onRelease
    }
end

function M:isSceneValid(playGameScene)
    return playGameScene and self:isBoardValid(playGameScene.board) and
            playGameScene.creds and playGameScene.creds.user and playGameScene.creds.user.id and true
end

function M:isBoardValid(board)
    return board and board.tileImages and board.tilesGroup and self:isGameModelValid(board.gameModel) and true
end

function M:isGameModelValid(gameModel)
    return gameModel and gameModel.moveNum and gameModel.player1Rack and gameModel.player2Rack and gameModel.player1 and gameModel.player2 and true
end

return M

