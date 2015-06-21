local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")
local math = require("math")
local json = require("json")

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

    M.addAnimationToBoard(board)

end

function M.isBoardValid(board)
    return board and board.tileImages and board.tilesGroup and board.gameModel and board.gameModel.moveNum and true
end

function M.addAnimationToBoard(board)
    local wordPos = M.getWordToAnimate(board)
    print("Word pos to animate:" .. json.encode(wordPos))
end

function M.getWordToAnimate(board)
    local N = board.N
    local longestLen = 0
    local chosenWord
    local startR, startC = math.random(N), math.random(N)
    for i = 1, N do
        for j = 1, N do
            local r, c = (startR + i) % N + 1, (startC + j) % N + 1
            local southWord = board:getWordCenteredAt(r, c, {1, 0})
            local eastWord = board:getWordCenteredAt(r, c, {0, 1})
            if southWord then
                local len = southWord[3] - southWord[1] + 1
                if longestLen < len then
                    longestLen = len
                    chosenWord = southWord
                end
            end
            if eastWord then
                local len = eastWord[4] - eastWord[2] + 1
                if longestLen < len then
                    longestLen = len
                    chosenWord = eastWord
                end
            end
        end
    end
    return chosenWord
end

return M
