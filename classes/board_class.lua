local board_class = {}
local board_class_mt = { __index = board_class }

local square = require("common.square")
local tile = require("common.tile")
local math = require("math")
local display = require("display")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local transition = require("transition")

local lists = require("common.lists")
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
	local rackTileImages = {}
	for i = 1, N do
		rackTileImages[i] = {}
	end

	print ("Creating new board with width=" .. width)

	local newBoard = {
		N = N,
		squares = squares,
		tiles = tiles,
		startX = startX,
		startY = startY,
		width = width,
		onGrabTiles = onGrabTiles,
		rackTileImages = rackTileImages
	}

	newBoard = setmetatable( newBoard, board_class_mt )
    newBoard:createBoardContainer()
    return newBoard
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
	local squareImages = {}
	for i = 1, N do
		squareImages[i] = {}
	end
	print("px per square=" .. pxPerSquare)

	for i = 1, N do
		for j = 1, N do
			local s = squares[i][j]
			local x = math.floor((j - 1) * pxPerSquare + pxPerSquare / 2 - width / 2)
			local y = math.floor((i - 1) * pxPerSquare + pxPerSquare / 2 - width / 2)
			local squareGroup = square.draw(s, x, y, pxPerSquareInt)
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

function board_class:getSquareContainingPoint(contentX, contentY)
	local squareImages = self.squareImages
	local N = self.N
	local containerBounds = self.boardContainer.contentBounds
	for i = 1, N do
		for j = 1, N do
			local tile = self.tileImages[i][j]
			if not tile then
				local squareBg = squareImages[i][j].squareBg
				local bounds = squareBg.contentBounds
				if bounds.xMax <= containerBounds.xMax and
				   bounds.xMin >= containerBounds.xMin and
				   bounds.yMax <= containerBounds.yMax and
				   bounds.yMin >= containerBounds.yMin and
				   contentX > bounds.xMin and contentX < bounds.xMax and
				   contentY > bounds.yMin and contentY < bounds.yMax then
				   return squareImages[i][j]
				end
			end
		end
	end
	return nil

end

function board_class:computeTileCoords(row, col)
	local pxPerSquare = self.width / self.N
	local x = math.floor((col - 1) * pxPerSquare + pxPerSquare / 2 - self.width / 2)
	local y = math.floor((row - 1) * pxPerSquare + pxPerSquare / 2 - self.width / 2)
	return x, y
end

function board_class:createTilesGroup(width)
	local tilesGroup = display.newGroup()
	local N = self.N
	local width = self.width
	local tiles = self.tiles
	local pxPerSquare = width / N
	local pxPerSquareInt = math.floor(pxPerSquare)

	local tileImages = {}
	for i = 1, N do
		tileImages[#tileImages + 1] = {}
	end

	for i = 1, N do
		for j = 1, N do
			local t = tiles[i][j]
			local x, y = self:computeTileCoords(i, j)
			local img = tile.draw(t, x, y, pxPerSquareInt)
			if img then
				img.board = self
				img.row = i
				img.col = j
				img.letter = t
				img:addEventListener( "touch", tileTouchListener )
				tilesGroup:insert(img)
			end
			tileImages[i][j] = img
		end
	end
	self.tileImages = tileImages
	self.tilesGroup = tilesGroup
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

function board_class:createBoardContainer()
	local width = self.width
	local boardContainer = display.newContainer(width, width)
	local boardGroup = display.newGroup()
	local squaresGroup = self:createSquaresGroup(width)
	local tilesGroup = self:createTilesGroup(width)
	local rackTilesGroup = display.newGroup()
    local boardTexture = common_ui.create_image("images/wood-texture.jpg", display.contentWidth, display.contentWidth, 0, 0)
    boardGroup:insert(boardTexture)
	boardGroup:insert(squaresGroup)
	boardGroup:insert(tilesGroup)
	boardGroup:insert(rackTilesGroup)
	boardGroup:addEventListener( "tap", getBoardTapListener(self) )
	self.boardGroup = boardGroup
	self.rackTilesGroup = rackTilesGroup

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
		self.tileImages[t.row][t.col] = nil
		t:removeSelf( )
	end
	self.grabbed = nil
	self.isGrabbing = false
end

function board_class:addTileFromRack(contentX, contentY, tileImage)
	local letter = tileImage.letter
	local squareImage = self:getSquareContainingPoint(contentX, contentY)
	if not squareImage or not letter then
		print("Not adding letter " .. tostring(letter) .. " to board at x = " .. contentX .. ", y = " .. contentY)
		return false
	end
	local row, col = squareImage.row, squareImage.col
	print ("Inserting tile at row = " .. row .. ", col = " .. col)
	print ("Inserting tile at x = " .. squareImage.x .. ", y = " .. squareImage.y)
	self.rackTilesGroup:insert(tileImage)
	-- modify width to account for scale
	local scale = self.boardGroup.xScale
	tileImage.width = tileImage.width / scale
	tileImage.height = tileImage.height / scale
	tileImage.x = squareImage.x
	tileImage.y = squareImage.y
	tileImage.row = row
	tileImage.col = col
	self.rackTileImages[row][col] = tileImage
	transition.to(tileImage, {
		width = squareImage.squareBg.width,
		height = squareImage.squareBg.height,
		onComplete = function(event)
			print("Finished adding letter " .. letter .. " to the board")
		end
		})
	
	return true

end

function board_class:removeRackTileFromBoard(tileImage)
	if tileImage.row and tileImage.col then
		self.rackTileImages[row][col] = nil
	end
	tileImage.row = nil
    tileImage.col = nil

end

function board_class:getCurrentPlayTilesMove()
	local orderedTiles = self:getOrderedRackTiles()
	if orderedTiles["errorMsg"] then
		return orderedTiles
	end
	-- Construct the actual word being played
	local letters, startR, startC, dir = self:getWordForPlayTilesMove(orderedTiles)
	if letters["errorMsg"] then
		return letters
	end

	local rackTileLetters = self:getLettersFromTiles(orderedTiles)

	-- Construct the move
	return {
		letters = letters:upper(),
		start = { r = startR - 1, c = startC - 1 },
		dir = dir,
		tiles = rackTileLetters,
		moveType = common_api.PLAY_TILES
	}
end

function board_class:getLettersFromTiles(tileImages)
	local letters = ""
	for i = 1, #tileImages do
		letters = letters .. tileImages[i].letter
	end
	return letters:upper()
end

function board_class:getWordForPlayTilesMove(orderedTiles)
	local N = self.N
	local tileImages = self.tileImages

	local row = orderedTiles[1].row
	local col = orderedTiles[1].col

	if (#orderedTiles == 1 and (tileImages[row][col - 1] or tileImages[row][col + 1])) or 
		#orderedTiles > 1 and orderedTiles[1].col < orderedTiles[2].col then -- East direction
		local startR, startC = self:getLastOccupied(row, col, {0, -1})
		local endR, endC = self:getLastOccupied(row, col, {0, 1})
		return self:getLettersInRange(startR, startC, endR, endC), startR, startC, "E"
	elseif (#orderedTiles == 1 and (tileImages[row - 1][col] or tileImages[row + 1][col])) or 
			#orderedTiles > 1 and orderedTiles[1].row < orderedTiles[2].row then -- South direction
		local startR, startC = self:getLastOccupied(row, col, {-1, 0})
		local endR, endC = self:getLastOccupied(row, col, {1, 0})
		return self:getLettersInRange(startR, startC, endR, endC), startR, startC, "S"
	else 
		return {errorMsg = "Invalid play"}
	end

end

function board_class:getLettersInRange(startR, startC, endR, endC)
	local tileImages = self.tileImages
	local rackTileImages = self.rackTileImages
	local letters = ""
	if startC < endC then
		local r = startR
		for j = startC, endC do
			if tileImages[r][j] and rackTileImages[r][j] then
				return {errorMsg = "Tiles from the rack can't be on top of tiles on the board!"}
			elseif tileImages[r][j] then
				letters = letters .. tileImages[r][j].letter
			elseif rackTileImages[r][j] then
				letters = letters .. rackTileImages[r][j].letter
			end
		end
		return letters
	elseif startR < endR then
		local c = startC
		for i = startR, endR do
			if tileImages[i][c] and rackTileImages[i][c] then
				return {errorMsg = "Tiles from the rack can't be on top of tiles on the board!"}
			elseif tileImages[i][c] then
				letters = letters .. tileImages[i][c].letter
			elseif rackTileImages[i][c] then
				letters = letters .. rackTileImages[i][c].letter
			end
		end
		return letters
	else
		if tileImages[startR][startC] then
			return tileImages[startR][startC].letter
		else
			return rackTileImages[startR][startC].letter
		end
	end

end

function board_class:getLastOccupied(row, col, dir)
	local r = row + dir[1]
	local c = col + dir[2]
	local tileImages = self.tileImages
	local rackTileImages = self.rackTileImages
	local N = self.N

	while r >= 1 and r <= N and c >= 1 and c <= N and 
		(tileImages[r][c] or rackTileImages[r][c]) do
		r = r + dir[1]
		c = c + dir[2]
	end
	return r - dir[1], c - dir[2]
end

function board_class:getOrderedRackTiles()
	local N = self.N
	local rackTileImages = self.rackTileImages
	local tileImages = self.tileImages
	local row, col
	-- Find the first rack tile on the board, traversing in row-major order
	local found = false
	for i = 1, N do
		if found then
			break
		end
		for j = 1, N do
			if found then
				break
			end
			if rackTileImages[i][j] then
				row = i
				col = j
				found = true
				break
			end
		end
	end
	if not row or not col then
		return {errorMsg = "You must place tiles on the board to play a move."}   --- we didn't find any rack tile images
	end

	local orderedTiles = { }
	local tileToEast
	local tileToSouth

	for j = col + 1, N do
		if rackTileImages[row][j] then
			tileToEast = rackTileImages[row][j]
			break
		end
	end

	for i = row + 1, N do
		if rackTileImages[i][col] then
			tileToSouth = rackTileImages[i][col]
			break
		end
	end

	if tileToEast and tileToSouth then
        print("Found tile to E at (" .. tileToEast.row .. "," .. tileToEast.col .. "): " .. tileToEast.letter)
        print("Found tile to S at (" .. tileToSouth.row .. "," .. tileToSouth.col .. "): " .. tileToSouth.letter)
		return {errorMsg = "You must place tiles in the same row or column with no empty spaces in between"}
	end

	-- Build the tiles for the play in order
	if tileToEast then
		for j = col, N do
			if rackTileImages[row][j] then
				if tileImages[row][j] then
					return {errorMsg = "Cannot place a tile from the rack on top of a tile on the board!"}
				end
				orderedTiles[#orderedTiles + 1] = rackTileImages[row][j]
			elseif not tileImages[row][j] then
				break
			end
		end
	elseif tileToSouth then 
		for i = row, N do
			if rackTileImages[i][col] then
				if tileImages[i][col] then
					return {errorMsg = "Cannot place a tile from the rack on top of a tile on the board!"}
				end
				orderedTiles[#orderedTiles + 1] = rackTileImages[i][col]
			elseif not tileImages[i][col] then
				break
			end
		end
	else
		orderedTiles[1] = rackTileImages[row][col]
	end

	-- Finally verify there aren't any additional tiles on the board that aren't included in the play
	for i = row, N do
		for j = 1, N do
			if rackTileImages[i][j] and lists.indexOf(orderedTiles, rackTileImages[i][j]) == 0 then
				return {errorMsg = "You must place tiles in the same row or column with no empty spaces in between"}
			end
		end
	end

	return orderedTiles

end

function board_class:destroy()
    self.boardContainer:removeSelf()
    self.boardContainer = nil
    self.boardGroup = nil
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