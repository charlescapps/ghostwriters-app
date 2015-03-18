--
-- Created by IntelliJ IDEA.
-- User: charlescapps
-- Date: 3/16/15
-- Time: 8:42 PM
-- To change this template use File | Settings | File Templates.
--
local POINTS = require("common.points")
local TILE = require("common.tile")
local math = require("math")
local display = require("display")
local native = require("native")
local transition = require("transition")

local points_bubble_class = {}
local points_bubble_class_mt = { __index = points_bubble_class }

-- Constants
local BUBBLE_HEIGHT = 200
local BUBBLE_WIDTH = 200
local PAD = 10


points_bubble_class.new = function(board)
    local pointsBubble = {
        board = board
    }
    return setmetatable(pointsBubble, points_bubble_class_mt)
end

function points_bubble_class:computePoints(playMove)
    if playMove["errorMsg"] then
        return 0
    end
    local board = self.board
    local startR, startC, dir, letters, rackTiles = playMove.start.r + 1, playMove.start.c + 1, playMove.dir, playMove.letters, playMove.tiles
    local points = 0
    local rackTilesIndex = 1
    if dir == "E" then
        for c = startC, startC + letters:len() - 1 do
            local tile = self.board.tiles[startR][c]
            if tile and tile ~= TILE.emptyTile then
               points = points + POINTS.getLetterPoints(tile)
            else
                local square = self.board.squares[startR][c]
                local rackLetter = rackTiles:sub(rackTilesIndex, rackTilesIndex)
                rackTilesIndex = rackTilesIndex + 1
                points = points + POINTS.getLetterPoints(rackLetter) * square.num
            end

        end
    elseif dir == "S" then
        for r = startR, startR + letters:len() - 1 do
            local tile = self.board.tiles[r][startC]
            if tile and tile ~= TILE.emptyTile then
                points = points + POINTS.getLetterPoints(tile)
            else
                local square = self.board.squares[r][startC]
                local rackLetter = rackTiles:sub(rackTilesIndex, rackTilesIndex)
                rackTilesIndex = rackTilesIndex + 1
                points = points + POINTS.getLetterPoints(rackLetter) * square.num
            end

        end
    end

    return points
end

function points_bubble_class:drawPointsBubble()
    self:removePointsBubble()
    local board = self.board
    local playMove = board:getCurrentPlayTilesMove()
    local points = self:computePoints(playMove)
    if points <= 0 then
        return nil
    end

    local letters = playMove.letters
    local pxPerSquare = board.width / board.N
    local r, c = playMove.start.r + 1, playMove.start.c + 1
    local squareGroup = board.squareImages[r][c]
    local x, y, rotateDegrees, textY, flip
    if playMove.dir == "E" then
       -- Place bubble above the play
       if squareGroup.y < 0 then
           -- Draw bubble below the word, centered
            x = squareGroup.x - pxPerSquare / 2 + letters:len() * pxPerSquare / 2
            y = squareGroup.y + pxPerSquare / 2 + BUBBLE_HEIGHT / 2 + PAD
            rotateDegrees, textY = 180, 10
            flip = false
       else
           -- Draw the bubble above the word, centered
           x = squareGroup.x - pxPerSquare / 2 + letters:len() * pxPerSquare / 2
           y = squareGroup.y - pxPerSquare / 2 - BUBBLE_HEIGHT / 2 - PAD
           rotateDegrees, textY = 0, -30
           flip = false
       end
    else
        if squareGroup.x < 0 then
            -- Draw bubble to the right of the word, centered
            x = squareGroup.x + pxPerSquare / 2 + BUBBLE_WIDTH / 2 + PAD
            y = squareGroup.y - pxPerSquare / 2 + letters:len() * pxPerSquare / 2
            rotateDegrees, textY = 0, -25
            flip = false
        else
            -- Draw bubble to the left of the word, centered
            x = squareGroup.x - pxPerSquare / 2 - BUBBLE_WIDTH / 2 - PAD
            y = squareGroup.y - pxPerSquare / 2 + letters:len() * pxPerSquare / 2
            rotateDegrees, textY = 0, -25
            flip = true
        end
    end

    self.bubbleDisplayGroup = self:drawBubble(points, x, y, rotateDegrees, textY, flip)
    board.boardGroup:insert(self.bubbleDisplayGroup)
    transition.to(self.bubbleDisplayGroup, { xScale = 1, yScale = 1, time = 500 })
end

function points_bubble_class:removePointsBubble()
    local currentBubble = self.bubbleDisplayGroup
    if currentBubble then
        transition.to(currentBubble, {time = 500, xScale = 0.1, yScale = 0.1, onComplete = function()
            currentBubble:removeSelf()
        end})
    end
end

function points_bubble_class:drawBubble(points, x, y, rotateDegrees, textY, flip)
    local group = display.newGroup()
    group.xScale, group.yScale = 0.1, 0.1 --initial scale very small!
    group.alpha = 0.8

    -- Draw the speech bubble
    local speechBubbleImg = display.newImageRect ("images/speech_bubble.png", BUBBLE_WIDTH, BUBBLE_HEIGHT)
    speechBubbleImg.rotation = rotateDegrees
    if flip then
        speechBubbleImg.xScale = -1
    end

    local pointsText = display.newText {
        text = points .. "\npoints!",
        font = native.systemFontBold,
        fontSize = 40,
        align = "center",
        width = 3 * BUBBLE_WIDTH / 4,
        height = 0,
        y = textY
    }
    pointsText:setFillColor(0, 0, 0)

    group:insert(speechBubbleImg)
    group:insert(pointsText)
    group.x, group.y = self:restrictToBoard(x, y)
    return group
end

function points_bubble_class:restrictToBoard(x, y)
    local MIN_X =  BUBBLE_WIDTH / 2 - self.board.width / 2
    local MAX_X = -BUBBLE_WIDTH / 2 + self.board.width / 2
    local MIN_Y =  BUBBLE_HEIGHT / 2 - self.board.width / 2
    local MAX_Y = -BUBBLE_HEIGHT / 2 + self.board.width / 2

    return math.min(math.max(x, MIN_X), MAX_X), math.min(math.max(y, MIN_Y), MAX_Y)
end

return points_bubble_class

