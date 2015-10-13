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

    local pos = 1
    for i = 1, str:len() do
        local c = str:sub(i, i)
        if c ~= "*" then
           -- Wildcard tiles are prefixed with a '*', but we are ignoring them for now.
            local row = math.floor((pos - 1) / N) + 1
            local col = (pos - 1) % N + 1
            tiles[row][col] = c
            pos = pos + 1
        end
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

function M.isUnitVector(vec)
    return vec[1] * vec[1] + vec[2] * vec[2] == 1
end

function M.go(r, c, dir, distance)
    distance = distance or 1
    if dir == "S" then
        return r + distance, c
    elseif dir == "E" then
        return r, c + distance
    elseif dir == "N" then
        return r - distance, c
    elseif dir == "W" then
        return r, c - distance
    end

    print("Error, invalid dir: " .. tostring(dir))
    return nil, nil

end

function M.getPerpDir(dir)
    if "E" == dir then
        return "S"
    elseif "S" == dir then
        return "E"
    end

    error("Invalid dir, can only get perp of E or S: " .. tostring(dir))
end

function M.negateDir(dir)
    if "E" == dir then
        return "W"
    elseif "W" == dir then
        return "E"
    elseif "S" == dir then
        return "N"
    elseif "N" == dir then
        return "S"
    end

    error("Invalid dir to find negation: " .. tostring(dir))
 end

return M

