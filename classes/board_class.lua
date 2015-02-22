local board_class = {}
local board_class_mt = { __index = board_class }

local square = require("common.square")
local tile = require("common.tile")
local math = require("math")
local display = require("display")
local common_ui = require("common.common_ui")
local transition = require("transition")

-- Constants


-- Pre-declaration of functions

local boardSizeToN
local parseSquares
local parseTiles
local tileTouchListener
local isConnected
local isUnitVector

function board_class.new(gameModel, startX, startY, width, onGrabTiles)
	local N = boardSizeToN(gameModel["boardSize"])
	local squares = parseSquares(gameModel["squares"], N)
	local tiles = parseTiles(gameModel["tiles"], N)

	print ("Creating new board with width=" .. width)

	local newBoard = {
		N = N,
		squares = squares,
		tiles = tiles,
		startX = startX,
		startY = startY,
		width = width,
		onGrabTiles = onGrabTiles
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

function board_class:getSquaresStr()
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

function board_class:getTilesStr()
	local N = self.N
	local tiles = self.tiles
	local str = ""
	for i = 1, N do
		for j = 1, N do
			str = str .. tiles[i][j] .. " "
		end
		str = str .. "\n"
	end
	return str
end

function board_class:createSquaresGroup(width)
	local squaresGroup = display.newGroup()
	local N = self.N
	local squares = self.squares
	local width = self.width
	local pxPerSquare = width / N
	local pxPerSquareInt = math.floor(pxPerSquare)
	print("px per square=" .. pxPerSquare)

	for i = 1, N do
		for j = 1, N do
			local s = squares[i][j]
			local x = math.floor((j - 1) * pxPerSquare + pxPerSquare / 2 - width / 2)
			local y = math.floor((i - 1) * pxPerSquare + pxPerSquare / 2 - width / 2)
			local squareGroup = square.draw(s, x, y, pxPerSquareInt)
			squaresGroup:insert(squareGroup)
		end
	end

	self.squaresGroup = squaresGroup
	return squaresGroup
end

function board_class:createTilesGroup(width)
	local tilesGroup = display.newGroup()
	local N = self.N
	local width = self.width
	local tiles = self.tiles
	local pxPerSquare = width / N
	local pxPerSquareInt = math.floor(pxPerSquare)

	for i = 1, N do
		for j = 1, N do
			local t = tiles[i][j]
			local x = math.floor((j - 1) * pxPerSquare + pxPerSquare / 2 - width / 2)
			local y = math.floor((i - 1) * pxPerSquare + pxPerSquare / 2 - width / 2)
			local img = tile.draw(t, x, y, pxPerSquareInt)
			if img then
				img.board = self
				img.row = i
				img.col = j
				img.letter = t
				img:addEventListener( "touch", tileTouchListener )
				tilesGroup:insert(img)
			end
		end
	end
	return tilesGroup

end

function board_class:zoomIn(scale, x, y)
	if not self.boardGroup then
		print("Error - board has no self.boardGroup display group. Cannot zoom in.")
		return 
	end
	self.isZoomed = true
	local params = {
		tag = "board_zoom_in",
		xScale = scale,
		yScale = scale,
		x = self:restrictX(2*self.startX - 2*x),
		y = self:restrictX(2*self.startY - 2*y)
	}
	transition.to(self.boardGroup, params)
end

function board_class:zoomOut()
	self.isZoomed = false
	local params = {
		tag = "board_zoom_out",
		xScale = 1,
		yScale = 1,
		x = 0,
		y = 0
	}
	transition.to(self.boardGroup, params)
end

function board_class:toggleZoom(scale, x, y)
	print ("Called board:toggleZoom")
	if self.isZoomed then
		self:zoomOut()
	else
		self:zoomIn(scale, x, y)
	end
end

function getBoardTapListener(board)
	return function(event)
		if not board.boardGroup then
			print("Board has no self.boardGroup. Cannot process tap event.")
			return true
		end

		if event.numTaps == 2 then
			board:toggleZoom(2, event.x - board.boardGroup.x, event.y - board.boardGroup.y)
		else

		end
		return true
	end
end

function board_class:createBoardGroup()
	local width = self.width
	local boardContainer = display.newContainer(width, width)
	local boardGroup = display.newGroup()
	local squaresGroup = self:createSquaresGroup(width)
	local tilesGroup = self:createTilesGroup(width)
	boardGroup:insert(squaresGroup)
	boardGroup:insert(tilesGroup)
	boardGroup:addEventListener( "tap", getBoardTapListener(self) )
	self.boardGroup = boardGroup

	boardContainer:insert(boardGroup)
	self.boardContainer = boardContainer
	boardContainer.x = self.startX
	boardContainer.y = self.startY
	return boardContainer
end

function board_class:restrictX(x)
	local width = self.width
	local MIN_X = - width / 2
	local MAX_X = width / 2
	if x < MIN_X then
		return MIN_X
	elseif x > MAX_X then
		return MAX_X
	else
		return x
	end
end

function board_class:cancel_grab()
	self.grabbed = nil
	self.isGrabbing = false
end

function board_class:complete_grab()
	for i = 1, #(self.grabbed) do
		local t = self.grabbed[i]
		self.tiles[t.row][t.col] = tile.emptyTile
		t:removeSelf( )
	end
	self.grabbed = nil
	self.isGrabbing = false
end

-- Local functions
tileTouchListener = function(event)
	local tile = event.target
	local board = tile.board
	if event.phase == "began" then
		print("Tile touch listener began!")
		board:cancel_grab() -- Clear all grab data 
		board.isGrabbing = true
		board.grabbed = {}
		board.grabbed[1] = tile
		return true
	elseif event.phase == "moved" then
		-- If this is another moved event on the same tile, then just return.
		local lastTile = board.grabbed and board.grabbed[#(board.grabbed)]
		if lastTile and lastTile.row == tile.row and lastTile.col == tile.col then
			return true 
		end
		print("Tile touch listener: moved for tile " .. tile.letter)
		if not board.isGrabbing then
			board:cancel_grab()
			return true
		end
		if tile.letter == tile.letter:upper( ) then
			print ("User grabbed uppercase letter, cancelling grab: " .. tile.letter)
			board:cancel_grab()
			return true
		end
		board.grabbed[#(board.grabbed) + 1] = tile

	elseif event.phase == "ended" then
		print("Tile touch listener: ended for tile " .. tile.letter)
		if not board.isGrabbing or not isConnected(board.grabbed) then
			board:cancel_grab()
			return true
		end
		board.onGrabTiles(board.grabbed)
	elseif event.phase == "cancelled" then
		board:cancel_grab()
	end
	return true
end

isConnected = function(tiles)
	if #tiles <= 1 then
		return true
	end

	local t1 = tiles[1] 
	local t2 = tiles[2]
	local vec = { t2.row - t1.row, t2.col - t1.col }

	if not isUnitVector(vec) then
		return false
	end

	for i = 2, #tiles do
		local tile = tiles[i]
		local prev = tiles[i-1]
		if tile.row ~= prev.row + vec[1] or tile.col ~= prev.col + vec[2] then
			return false
		end
	end

	return true
end

isUnitVector = function(vec)
	return vec[1] * vec[1] + vec[2] * vec[2] == 1
end

return board_class