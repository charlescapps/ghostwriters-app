local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}

local TIP_NAME = "grab_tiles_tip"

function M.triggerTipOnCondition(board)
    if not M.isBoardValid(board) then
        print("ERROR - invalid game model, cannot trigger grab tiles tip.")
        return
    end

    if board.gameModel.moveNum == 1 then
        print("Triggering grab tiles tipe because moveNum == 1.")
        M.showTip(board)
    end
end

function M.showTip(board)
    if not tips_persist.isTipViewed(TIP_NAME) then
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        tips_modal.new("On the first turn, your hand is empty.\n\nSwipe words on the board to get letters.", nil, onClose):show()
    end

    M.addAnimationToBoard(board.tileImages, board.tilesGroup)

end

function M.isBoardValid(board)
    return board and board.tileImages and board.tilesGroup and board.gameModel and board.gameModel.moveNum and true
end

function M.addAnimationToBoard(tileImages, tilesGroup)

end

return M
