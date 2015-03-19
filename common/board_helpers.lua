local math = require("math")
local square = require("common.square")

local M = {}

function M.parseSquares(str, N)
    local squares = {}
    for i = 1, N do
        squares[i] = {}
    end

    for i = 1, str:len() do
        local c = str:sub(i, i)
        local sqType = square.valueOf(c)
        local row = math.floor((i - 1) / N) + 1
        local col = (i - 1) % N + 1
        squares[row][col] = sqType
    end

    return squares
end

function M.parseTiles(str, N)
    local tiles = {}
    for i = 1, N do
        tiles[i] = {}
    end

    for i = 1, str:len() do
        local c = str:sub(i, i)
        local row = math.floor((i - 1) / N) + 1
        local col = (i - 1) % N + 1
        tiles[row][col] = c
    end

    return tiles
end

function M.getSquaresStr(N, squares)
    local str = ""
    for i = 1, N do
        for j = 1, N do
            str = str .. squares[i][j].num .. " "
        end
        str = str .. "\n"
    end
    return str
end

function M.getTilesStr(N, tiles)
    local str = ""
    for i = 1, N do
        for j = 1, N do
            str = str .. tiles[i][j] .. " "
        end
        str = str .. "\n"
    end
    return str
end

return M

