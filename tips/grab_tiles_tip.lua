local common_ui = require("common.common_ui")
local display = require("display")
local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")
local math = require("math")
local json = require("json")
local transition = require("transition")
local timer = require("timer")
local table = require("table")

local M = {}
local meta = { __index = M }

local TIP_NAME = "grab_tiles_tip"
local GRAB_TILES_TIP_TAG = "grab_tiles_anim"
local MS_PER_TILE = 500

function M.new(playGameScene)
    local grabTilesTip = {
        playGameScene = playGameScene,
        arrowImages = {}
    }
    return setmetatable(grabTilesTip, meta)
end

function M:triggerTipOnCondition()
    if not self:isSceneValid(self.playGameScene) then
        print("ERROR - invalid play game scene, cannot trigger grab tiles tip.")
        return
    end

    local gameModel = self.playGameScene.board.gameModel
    local user = self.playGameScene.creds.user

    if gameModel.moveNum == 1 or
       gameModel.moveNum == 2 and user.id == gameModel.player2 then
        print("Triggering grab tiles tipe because it's the user's first turn of the game.")
        return self:showTip()
    end
end

function M:showTip()
    local board = self.playGameScene.board
    local showedModal = false
    if not tips_persist.isTipViewed(TIP_NAME) then
        showedModal = true
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        tips_modal.new("Each turn you can either grab letters or play words.\n\nOn the first turn, your hand is empty. Swipe letters in a line to grab letters.",
            nil, onClose, "images/grab_tiles_tip.jpg", 500, 63, 0, 70):show()
    end

    self:addAnimationToBoard()
    return showedModal
end

function M:isSceneValid(playGameScene)
   return playGameScene and self:isBoardValid(playGameScene.board) and
          playGameScene.creds and playGameScene.creds.user and playGameScene.creds.user.id and true
end

function M:isBoardValid(board)
    return board and board.tileImages and board.tilesGroup and board.gameModel and board.gameModel.moveNum and true
end

function M:addAnimationToBoard()
    local board = self.playGameScene.board
    local wordPos = self:getWordToAnimate()
    if not wordPos then
        print("ERROR - word found to animate is nil")
        return
    end
    print("Word pos to animate:" .. json.encode(wordPos))

    self:animateArrows(board, wordPos)

end

function M:animateArrows(board, wordPos)
    --print("wordPos(1,2,3,4)=" .. wordPos[1] .. "," .. wordPos[2] .. "," .. wordPos[3] .. "," .. wordPos[4])
    local startSquare = board.squareImages[wordPos[1]][wordPos[2]]
    local endSquare = board.squareImages[wordPos[3]][wordPos[4]]

    local dir = wordPos[1] == wordPos[3] and "E" or "S"

    local wordLen = dir == "E" and (wordPos[4] - wordPos[2] + 1) or (wordPos[3] - wordPos[1] + 1)

    -- Draw the arrows, initially invisible.
    local callback = function()
        if not common_ui.isValidDisplayObj(startSquare) or
           not common_ui.isValidDisplayObj(endSquare) or
           not startSquare.width or
           not endSquare.width
        then
           self:stopTip()
           return
        end
        self:startArrow(dir, startSquare, endSquare, wordLen)
    end
    self.timerObj = timer.performWithDelay( MS_PER_TILE, callback, -1 )
end

function M:startArrow(dir, startSquare, endSquare, wordLen)

    local arrowImg = self:drawArrow(startSquare, dir)

    if not arrowImg then
        return
    end

    self.arrowImages[#self.arrowImages + 1] = arrowImg

    local function onHalfComplete(img)

        local function onTotalComplete(img2)
            common_ui.safeRemove(img2)
            local index = table.indexOf(self.arrowImages, img2)
            if index then
                table.remove(self.arrowImages, index)
            end
        end

        transition.to(img, {
            tag = GRAB_TILES_TIP_TAG,
            x = dir == "E" and (endSquare.x + endSquare.width) or endSquare.x,
            y = dir == "S" and (endSquare.y + endSquare.height) or endSquare.y,
            alpha = 0,
            time = MS_PER_TILE * (wordLen - 1) / 2,
            onComplete = onTotalComplete
        })
    end

    local halfX = dir == "E" and startSquare.x + (endSquare.x - startSquare.x + startSquare.width) / 2
        or startSquare.x

    local halfY = dir == "S" and startSquare.y + (endSquare.y - startSquare.y + startSquare.height) / 2
        or startSquare.y

    transition.to(arrowImg, {
        tag = GRAB_TILES_TIP_TAG,
        x = halfX,
        y = halfY,
        alpha = 0.9,
        time = MS_PER_TILE * (wordLen - 1) / 2,
        onComplete = onHalfComplete
    })
end

function M:stopTip()
    transition.cancel(GRAB_TILES_TIP_TAG)
    local timerObj = self.timerObj
    if timerObj then
        timer.cancel(self.timerObj)
        self.timerObj = nil
    end

    for i = 1, #self.arrowImages do
        common_ui.safeRemove(self.arrowImages[i])
    end
    self.arrowImages = {}
end

function M:drawArrow(startSquare, dir)
    if not common_ui.isValidDisplayObj(startSquare) or not startSquare.width then
        return nil
    end
    local imgFile = dir == "E" and "images/arrow-east.png" or "images/arrow-south.png"
    local width = startSquare.width * 0.8
    local img = display.newImageRect(imgFile, width, width)
    img.x, img.y = startSquare.x, startSquare.y
    img.alpha = 0.3
    self.playGameScene.board.boardGroup:insert(img)
    img:toFront()
    return img
end

function M:getWordToAnimate()
    local board = self.playGameScene.board
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
