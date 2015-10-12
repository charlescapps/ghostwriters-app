local common_ui = require("common.common_ui")
local board_helpers = require("common.board_helpers")
local json = require("json")

local timer = require("timer")

local M = {}
local __meta = { __index = M }

function M.new(board)
    local errHigh = {
        board = board
    }

    return setmetatable(errHigh, __meta)
end

function M:highlightErrorWord(errorWord)
    print("Error word:" .. json.encode(errorWord))

    if type(errorWord) ~= "table" then
        return
    end

    if not self.board then
        return
    end

    local start, dir = errorWord.start, errorWord.dir
    if not start or not dir then
        return
    end

    local startR, startC = start.r + 1, start.c + 1

    local errorTiles = self:gatherErrorTiles(startR, startC, dir)

    self:highlightErrorTiles(errorTiles)
end

function M:gatherErrorTiles(startR, startC, dir)
    local tileImages = self.board and self.board.tileImages
    local rackTileImages = self.board and self.board.rackTileImages

    if not tileImages or not rackTileImages then
        return
    end

    local errorTiles = {}
    local r, c = startR, startC

    while true do
       local tileImage = tileImages and tileImages[r] and tileImages[r][c]
       if tileImage then
          errorTiles[#errorTiles + 1] = tileImage
       else
          local rackTile = rackTileImages and rackTileImages[r] and rackTileImages[r][c]
          if rackTile then
              errorTiles[#errorTiles + 1] = rackTile
          else
              return errorTiles
          end
       end

        r, c = board_helpers.go(r, c, dir, 1)
    end

    return errorTiles
end


function M:highlightErrorTiles(errorTiles)
    self:unHighlightErrorTiles(self.errorTiles)

    if type(errorTiles) ~= "table" then
        return
    end

    self.errorTiles = errorTiles

    for i = 1, #errorTiles do
       self:highlightRed(errorTiles[i])
    end

    self.timerId = timer.performWithDelay(4000, function()
        self:unHighlightErrorTiles(errorTiles)
    end)

end

function M:highlightRed(tile)
    if not common_ui.isValidDisplayObj(tile) then
        return
    end

    tile.fill.effect = "filter.colorMatrix"

    tile.fill.effect.coefficients =
    {
        1, 0, 0, 0,  --red coefficients
        0, 1, 0, 0,  --green coefficients
        0, 0, 1, 0,  --blue coefficients
        0, 0, 0, 1   --alpha coefficients
    }

    tile.fill.effect.bias = { .6, 0.1, 0.1, 0 }
end

function M:unHighlightPrevErrorTiles()
    self:unHighlightErrorTiles(self.errorTiles)
    self.errorTiles = nil

    if self.timerId then
        timer.cancel(self.timerId)
        self.timerId = nil
    end
end


function M:unHighlightErrorTiles(errorTiles)
    if not errorTiles then
        return
    end

    for i = 1, #errorTiles do
       self:unHighlightTile(errorTiles[i])
    end

end

function M:unHighlightTile(tile)
    if not common_ui.isValidDisplayObj(tile) then
        return
    end

    tile.fill.effect = nil
end


return M

