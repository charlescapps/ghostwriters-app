local board_class = {}
local board_class_mt = { __index = board_class }

local square = require("common.square")
local math = require("math")
local display = require("display")
local common_ui = require("common.common_ui")

-- Constants


-- Pre-declaration of functions

local boardSizeToN
local parseSquares
local parseTiles

function board_class.new(gameModel)
	local N = boardSizeToN(gameModel["boardSize"])
	local squares = parseSquares(gameModel["squares"], N)
	local tiles = parseTiles(gameModel["tiles"], N)

	local newBoard = {
		N = N,
		squares = squares,
		tiles = tiles
	}

	return setmetatable( newBoard, board_class_mt )
end

-- Local helpers --
boardSizeToN = function(boardSize)
	if boardSize == "TALL" then
		return 9
	elseif 
		boardSize == "GRANDE" then
		return 13
	elseif 
		boardSize == "VENTI" then
		return 15
	end
	error("Invalid board size: " .. boardSize)

end

parseSquares = function(str, N)
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

parseTiles = function(str, N)
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

-- Board class Methods --

function board_class:toString()
	local N = self.N
	local squares = self.squares
	local str = ""
	for i = 1, N do
		for j = 1, N do
			str = str .. squares[i][j].num .. " "
		end
		str = str .. "\n"
	end
	return str
end

function board_class:createSquaresGroup(width)
	local squaresGroup = display.newGroup()
	local N = self.N
	local squares = self.squares
	local pxPerSquare = math.floor(width / N)
	print("px per square=" .. pxPerSquare)

	for i = 1, N do
		for j = 1, N do
			local s = squares[i][j]
			local x = (j - 1) * pxPerSquare + math.floor(pxPerSquare / 2)
			local y = (i - 1) * pxPerSquare + math.floor(pxPerSquare / 2)
			local squareGroup = square.draw(s, x, y, pxPerSquare)
			squaresGroup:insert(squareGroup)
		end
	end

	self.squaresGroup = squaresGroup
	return squaresGroup

end

return board_class