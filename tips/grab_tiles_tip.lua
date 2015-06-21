local common_ui = require("common.common_ui")
local display = require("display")
local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")
local math = require("math")
local json = require("json")
local transition = require("transition")
local timer = require("timer")

local M = {}
local meta = { __index = M }

local TIP_NAME = "grab_tiles_tip"
local GRAB_TILES_TIP_TAG = "grab_tiles_anim"
local MS_PER_TILE = 500

function M.new(board)
    local grabTilesTip = {
        board = board,
        arrowImages = {}
    }
    return setmetatable(grabTilesTip, meta)
end

function M:triggerTipOnCondition()
    if not self:isBoardValid(self.board) then
        print("ERROR - invalid game model, cannot trigger grab tiles tip.")
        return
    end

    if self.board.gameModel.moveNum == 1 then
        print("Triggering grab tiles tipe because moveNum == 1.")
        self:showTip()
    end
end

function M:showTip()
    local board = self.board
    if not tips_persist.isTipViewed(TIP_NAME) then
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        tips_modal.new("On the first turn, your hand is empty.\n\nSwipe words on the board to get letters.", nil, onClose):show()
    end

    self:addAnimationToBoard()

end

function M:isBoardValid(board)
    return board and board.tileImages and board.tilesGroup and board.gameModel and board.gameModel.moveNum and true
end

function M:addAnimationToBoard()
    local board = self.board
    local wordPos = self:getWordToAnimate()
    if not wordPos then
        print("ERROR - word found to animate is nil")
        return
    end
    print("Word pos to animate:" .. json.encode(wordPos))

    self:animateArrows(board, wordPos)

end

function M:animateArrows(board, wordPos)
    print("wordPos(1,2,3,4)=" .. wordPos[1] .. "," .. wordPos[2] .. "," .. wordPos[3] .. "," .. wordPos[4])
    local startTile = board.tileImages[wordPos[1]][wordPos[2]]
    local endTile = board.tileImages[wordPos[3]][wordPos[4]]

    local dir = wordPos[1] == wordPos[3] and "E" or "S"

    local wordLen = dir == "E" and (wordPos[4] - wordPos[2] + 1) or (wordPos[3] - wordPos[1] + 1)

    -- Draw the arrows, initially invisible.
    local numArrows = wordLen - 1
    for i = 1, numArrows do
       self.arrowImages[i] = self:drawArrow(startTile, dir)
    end

    for i = 1, numArrows do
        local arrowImg = self.arrowImages[i]
        local callback = function()
            self:startArrow(arrowImg, startTile, endTile, wordLen)
        end
        timer.performWithDelay((i - 1) * MS_PER_TILE, callback)
    end


end

function M:startArrow(arrowImg, startTile, endTile, wordLen)

    local function onComplete(img)
        img.x, img.y = startTile.x, startTile.y
        img.alpha = 0
        self:startArrow(img, startTile, endTile, wordLen)
    end

    transition.to(arrowImg, {
        tag = GRAB_TILES_TIP_TAG,
        x = endTile.x,
        y = endTile.y,
        alpha = 1,
        time = MS_PER_TILE * (wordLen - 1),
        onComplete = onComplete
    })
end

function M:stopTip()
    transition.cancel(GRAB_TILES_TIP_TAG)
    for i = 1, #self.arrowImages do
        common_ui.safeRemove(self.arrowImages[i])
    end
end

function M:drawArrow(startTile, dir)
    local imgFile = dir == "E" and "images/arrow-east.png" or "images/arrow-south.png"
    local width = startTile.width * 0.8
    local img = display.newImageRect(imgFile, width, width)
    img.x, img.y = startTile.x, startTile.y
    img.alpha = 0
    self.board.tilesGroup:insert(img)
    return img
end

function M:getWordToAnimate()
    local board = self.board
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
