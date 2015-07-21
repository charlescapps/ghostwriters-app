local mini_board_class = {}
local mini_board_class_mt = { __index = mini_board_class }

local board_helpers = require("common.board_helpers")
local square = require("common.square")
local tile = require("common.tile")
local math = require("math")
local display = require("display")

-- Constants
local TILE_PADDING = 1

function mini_board_class.new(gameModel, width, padding, onlyShowQuestionMarks)
    local N = gameModel.numRows
    local squares = board_helpers.parseSquares(gameModel["squares"], N)
    local tiles = board_helpers.parseTiles(gameModel["tiles"], N)
    local rackTileImages = {}
    for i = 1, N do
        rackTileImages[i] = {}
    end

    local newBoard = {
        gameModel = gameModel,
        width = width,
        padding = padding,
        onlyShowQuestionMarks = onlyShowQuestionMarks,
        N = N,
        squares = squares,
        tiles = tiles
    }

    newBoard = setmetatable( newBoard, mini_board_class_mt )

    newBoard:createBoardGroup()
    return newBoard
end

-- Board class Methods --

function mini_board_class:computeTileCoords(r, c)
    local pxPerSquare = self.width / self.N
    local x = math.floor((c - 1) * pxPerSquare + pxPerSquare / 2 - self.width / 2)
    local y = math.floor((r - 1) * pxPerSquare + pxPerSquare / 2 - self.width / 2)
    return x, y
end

function mini_board_class:createSquaresGroup(width)
    local squaresGroup = display.newGroup()
    local N = self.N
    local squares = self.squares
    local width = self.width
    local pxPerSquare = width / N
    local pxPerSquareInt = math.floor(pxPerSquare)
    local squareImages = {}
    for i = 1, N do
        squareImages[i] = {}
    end

    for i = 1, N do
        for j = 1, N do
            local s = squares[i][j]
            local x, y = self:computeTileCoords(i, j)
            local squareGroup = square.draw(square.NORMAL, x, y, pxPerSquareInt, self.gameModel.boardSize)
            squaresGroup:insert(squareGroup)
            squareImages[i][j] = squareGroup
            squareGroup.row = i
            squareGroup.col = j
        end
    end

    self.squaresGroup = squaresGroup
    self.squareImages = squareImages
    return squaresGroup
end

function mini_board_class:computeTileCoords(row, col)
    local pxPerSquare = self.width / self.N
    local x = math.floor((col - 1) * pxPerSquare + pxPerSquare / 2 - self.width / 2)
    local y = math.floor((row - 1) * pxPerSquare + pxPerSquare / 2 - self.width / 2)
    return x, y
end

function mini_board_class:createTilesGroup()
    local tilesGroup = display.newGroup()
    local N = self.N
    local width = self.width
    local tiles = self.tiles
    local pxPerSquare = width / N
    local pxPerSquareInt = math.floor(pxPerSquare)
    local tileWidth = pxPerSquareInt - TILE_PADDING * 2

    local tileImages = {}
    for i = 1, N do
        tileImages[#tileImages + 1] = {}
    end

    for i = 1, N do
        for j = 1, N do
            local t = self.onlyShowQuestionMarks and tiles[i][j] ~= tile.emptyTile and '?' or tiles[i][j]
            local x, y = self:computeTileCoords(i, j)
            local img = tile.draw(t, x, y, tileWidth, false, self.gameModel.boardSize)
            if img then
                img.board = self
                img.row = i
                img.col = j
                img.letter = t

                tilesGroup:insert(img)
            end
            tileImages[i][j] = img
        end
    end
    self.tileImages = tileImages
    self.tilesGroup = tilesGroup
    return tilesGroup
end

function mini_board_class:createBoardGroup()
    local width, padding = self.width, self.padding

    local boardGroup = display.newGroup()
    local squaresGroup = self:createSquaresGroup(width)
    local tilesGroup = self:createTilesGroup(width)

    local boardTexture = display.newImageRect("images/board_bg_texture.png", width + padding, width + padding)

    self.boardGroup = boardGroup
    self.boardTexture = boardTexture

    boardGroup:insert(boardTexture)
    boardGroup:insert(squaresGroup)
    boardGroup:insert(tilesGroup)

    return boardGroup
end

function mini_board_class:destroy()
    self.boardGroup:removeSelf()
    self.boardGroup = nil
end

return mini_board_class