local board_class = {}
local board_class_mt = { __index = board_class }

local square = require("common.square")
local math = require("math")


local boardSizeToN
local parseSquares

function board_class.new(gameModel)
	local N = boardSizeToN(gameModel["boardSize"])
	local squares = parseSquares(gameModel["squares"], N)

	local newBoard = {
		N = N,
		squares = squares
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
		print ("row=" .. row .. ", col=" .. col .. ", sqType = " .. sqType.num .. ", c=" .. c)
		squares[row][col] = sqType
	end

	return squares
end

-- Board class Methods --

function board_class:printSquares()
	local N = self.N
	local squares = self.squares
	for i = 1, N do
		for j = 1, N do
			print (squares[i][j].num .. " ")
		end
		print ("\n")
	end
end

return board_class