local board_class = {}
local board_class_mt = { __index = board_class }

local square = require("common.square")
local tile = require("common.tile")
local points_bubble_class = require("classes.points_bubble_class")
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
local isConnected
local isUnitVector

function board_class.new(gameModel, startX, startY, width, padding, onGrabTiles)
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
        padding = padding,
		onGrabTiles = onGrabTiles,
		rackTileImages = rackTileImages,
        gameModel = gameModel
    }

	newBoard = setmetatable( newBoard, board_class_mt )

    newBoard.pointsBubble = points_bubble_class.new(newBoard)

    newBoard:createBoardContainer()
    return newBoard
end

function board_class:getZoomScale()
    return self.N / 5
end

function board_class:disableInteraction()
    print("board: disabling interaction")
    self.interactionDisabled = true
end

function board_class:enableInteraction()
    print("board: enabling interaction")
    self.interactionDisabled = nil
end

-- Local helpers --
boardSizeToN = function(boardSize)
	if boardSize == common_api.SMALL_SIZE then
		return 5
	elseif 
		boardSize == common_api.MEDIUM_SIZE then
		return 9
	elseif 
		boardSize == common_api.LARGE_SIZE then
		return 13
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

function board_class:isGameFinished()
    return self.gameModel.gameResult ~= common_api.IN_PROGRESS
end

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

function board_class:computeTileCoords(r, c)
    local pxPerSquare = self.width / self.N
    local x = math.floor((c - 1) * pxPerSquare + pxPerSquare / 2 - self.width / 2)
    local y = math.floor((r - 1) * pxPerSquare + pxPerSquare / 2 - self.width / 2)
    return x, y
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
			local x, y = self:computeTileCoords(i, j)
			local squareGroup = square.draw(s, x, y, pxPerSquareInt, self.gameModel.boardSize)
			squaresGroup:insert(squareGroup)
			squareImages[i][j] = squareGroup
			squareGroup.row = i
			squareGroup.col = j
		end
	end

	self.squaresGroup = squaresGroup
	self.squareImages = squareImages
    squaresGroup:addEventListener("touch", self:getSquaresGroupTouchListener())
	return squaresGroup
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

				tilesGroup:insert(img)
			end
			tileImages[i][j] = img
		end
    end
    if not self:isGameFinished() then
        tilesGroup:addEventListener("touch", self:getTilesGroupTouchListener())
    end
	self.tileImages = tileImages
	self.tilesGroup = tilesGroup
	return tilesGroup

end

function board_class:getSquaresGroupTouchListener()
    return function(event)
        if self.interactionDisabled or not self.isZoomed then
            return true
        end
        if event.phase == "began" then
           print("Sqaures touch listener: began")
           display.getCurrentStage():setFocus(event.target)
           self.boardGroupStartX, self.boardGroupStartY = self.boardGroup.x, self.boardGroup.y
        elseif event.phase == "moved" then
            local xLocal, yLocal = self.boardContainer:contentToLocal(event.x, event.y)
            local xStartLocal, yStartLocal = self.boardContainer:contentToLocal(event.xStart, event.yStart)
            local scale = self:getZoomScale()
            local xDelta, yDelta = xLocal - xStartLocal, yLocal - yStartLocal
            self.boardGroup.x = self:restrictX(self.boardGroupStartX + xDelta, scale)
            self.boardGroup.y = self:restrictX(self.boardGroupStartY + yDelta, scale)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            self.boardGroupStartX, self.boardGroupStartY = nil, nil
            display.getCurrentStage():setFocus(nil)
        end
    end
end

function board_class:getTilesGroupTouchListener()
    return function(event)
        if self.interactionDisabled then
            return true
        end
        if event.phase == "began" then
            print("Tiles group touch listener: began")
            local myTile = self:tileForCoords(event.x, event.y)
            -- If the touch event isn't over a grabbable tile
            if myTile == nil or myTile.tileType ~= tile.ORIGINAL_TILE then
                print("Cannot grab tile: " .. myTile.letter)
                return true
            end
            display.getCurrentStage():setFocus(event.target)
            self.isGrabbing = true
            self.grabbed = { myTile }
            self:addGrabEffect(myTile)
            return true
        elseif event.phase == "moved" then
            -- If we aren't grabbing, then just return.
            if not self.isGrabbing then
                print("isGrabbing not true, return from 'moved' phase")
                return true
            end

            local myTile = self:tileForCoords(event.x, event.y)
            if not myTile then
                return true
            end
            -- If this is another moved event on the same tile, then just return.
            local lastTile = self.grabbed and self.grabbed[#(self.grabbed)]
            if lastTile and lastTile.row == myTile.row and lastTile.col == myTile.col then
                return true
            end
            if myTile.tileType ~= tile.ORIGINAL_TILE then
                print ("User grabbed a non-grabbable tile, cancelling grab: " .. myTile.letter)
                self:cancel_grab()
                return true
            end
            self:addGrabEffect(myTile)
            self.grabbed[#(self.grabbed) + 1] = myTile

        elseif event.phase == "ended" or event.phase == "cancelled" then
            print("Tiles Group touch listener: " .. event.phase)
            display.getCurrentStage():setFocus(nil)
            if not self.isGrabbing or not isConnected(self.grabbed) then
                self:cancel_grab()
                return true
            end
            self.onGrabTiles(self.grabbed)
        end
        return true
    end
end

function board_class:rowColForCoords(xContent, yContent)
    local x, y = self.tilesGroup:contentToLocal(xContent, yContent)
    local N, width = self.N, self.width
    local pxPerSquare = width / N
    local c = math.floor((x + self.width / 2) / pxPerSquare + 1)
    local r = math.floor((y + self.width / 2) / pxPerSquare + 1)
    return r, c
end

function board_class:tileForCoords(xContent, yContent)
    local r, c = self:rowColForCoords(xContent, yContent)
    if r < 1 or r > self.N or c < 1 or c > self.N then
        return nil
    end
    return self.tileImages[r][c]
end

function board_class:squareForCoords(xContent, yContent)
    local r, c = self:rowColForCoords(xContent, yContent)
    if r < 1 or r > self.N or c < 1 or c > self.N then
        return nil
    end
    return self.squareImages[r][c]
end

function board_class:zoomIn(scale, x, y)
	if not self.boardGroup then
		print("Error - board has no self.boardGroup display group. Cannot zoom in.")
		return 
	end
	-- Do not zoom in the tiny board.
	if self.gameModel.boardSize == common_api.SMALL_SIZE then
		return
	end
	self.isZoomed = true
	local params = {
		tag = "board_zoom_in",
		xScale = scale,
		yScale = scale,
		x = self:restrictX(scale * (self.startX - x), scale),
		y = self:restrictX(scale * (self.startY - y), scale)
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
        if board.interactionDisabled then
            return true
        end
		if not board.boardGroup then
			print("Board has no self.boardGroup. Cannot process tap event.")
			return true
		end

		if event.numTaps == 2 then
            local zoomScale = board:getZoomScale()
			board:toggleZoom(zoomScale, event.x - board.boardGroup.x, event.y - board.boardGroup.y)
		else

		end
		return true
	end
end

function board_class:createBoardContainer()
	local width, padding = self.width, self.padding
    local startX, startY = self.startX, self.startY
	local boardContainer = display.newContainer(width + padding, width + padding)
    boardContainer.x, boardContainer.y = startX, startY

	local boardGroup = display.newGroup()
	local squaresGroup = self:createSquaresGroup(width)
	local tilesGroup = self:createTilesGroup(width)
	local rackTilesGroup = display.newGroup()
    local boardTexture = common_ui.create_image("images/board_bg_texture.png", width + padding, width + padding, 0, 0)

	self.boardGroup = boardGroup
	self.rackTilesGroup = rackTilesGroup
    self.boardContainer = boardContainer
    self.boardTexture = boardTexture

    boardGroup:insert(boardTexture)
    boardGroup:insert(squaresGroup)
    boardGroup:insert(tilesGroup)
    boardGroup:insert(rackTilesGroup)
    boardGroup:addEventListener( "tap", getBoardTapListener(self) )

	boardContainer:insert(boardGroup)

	return boardContainer
end

function board_class:restrictX(x, scale)
	local width = self.width
    local scaledWidth = scale * width
	local MIN_X = -scaledWidth / 2 + width / 2
	local MAX_X = scaledWidth / 2 - width / 2
	if x < MIN_X then
		return MIN_X
	elseif x > MAX_X then
		return MAX_X
	else
		return x
	end
end

function board_class:cancel_grab()
    print("Cancelling grab")
    if self.grabbed then
        for i = 1, #(self.grabbed) do
            local grabbedTileImage = self.grabbed[i]
            if grabbedTileImage then
                self:removeGrabEffect(grabbedTileImage)
            end
        end
    end
	self.grabbed = nil
	self.isGrabbing = false
end

function board_class:addTileFromRack(contentX, contentY, tileImage)
	local letter = tileImage.letter
	local squareImage = self:squareForCoords(contentX, contentY)
	if not squareImage or not letter then
		print("Not adding letter " .. tostring(letter) .. " to board at x = " .. contentX .. ", y = " .. contentY)
		return false
	end
	local row, col = squareImage.row, squareImage.col
    if self.tileImages[row][col] or self.rackTileImages[row][col] then
        print("Tile already present at (" .. row .. ", " .. col .. ")")
        return false
    end
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
        time = 250,
		onComplete = function(event)
			print("Finished adding letter " .. letter .. " to the board")
            self.pointsBubble:drawPointsBubble()
		end
		})
	
	return true

end

function board_class:removeRackTileFromBoard(tileImage)
    local row, col = tileImage.row, tileImage.col
	if row and col then
        local wasRackTile = self.rackTileImages[row][col] ~= nil
		self.rackTileImages[row][col] = nil
        if wasRackTile then
            self.pointsBubble:drawPointsBubble()
        end
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
	elseif (#orderedTiles == 1 and (row > 1 and tileImages[row - 1][col] or row < N and tileImages[row + 1][col])) or 
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

function board_class:findFirstRackTile()
    local N = self.N
    local rackTileImages = self.rackTileImages
    -- Find the first rack tile on the board, traversing in row-major order
    for i = 1, N do
        for j = 1, N do
            if rackTileImages[i][j] then
                return rackTileImages[i][j]
            end
        end
    end
    return nil
end

function board_class:getOrderedRackTiles()
	local N = self.N
	local rackTileImages = self.rackTileImages
	local tileImages = self.tileImages
	-- Find the first rack tile on the board, traversing in row-major order
	local firstRackTile = self:findFirstRackTile()
	if not firstRackTile then
		return {errorMsg = "You must place tiles on the board to play a move."}   --- we didn't find any rack tile images
    end
    local row, col = firstRackTile.row, firstRackTile.col

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

function board_class:addGrabEffect(tileImage)
    local r, c = tileImage.row, tileImage.col
    local offset = tileImage.width * 0.1
    local randomAngle = math.random(21) - 11

    local squareGroup = self.squareImages[r][c]
    local sqType = self.squares[r][c]

    local shadedSquareGroup = square.drawShadedSquare(sqType, squareGroup.x, squareGroup.y, squareGroup.width, self.gameModel.boardSize)
    squareGroup.shadedSquareGroup = shadedSquareGroup

    self.squaresGroup:insert(shadedSquareGroup)
    shadedSquareGroup:toFront()

    tileImage:toFront()
    transition.to(tileImage, {x = tileImage.x + offset, y = tileImage.y - offset, rotation = randomAngle, time = 100})
    --transition.dissolve(squareGroup, shadedSquareGroup, 250)
end

function board_class:removeGrabEffect(tileImage)
    transition.cancel(tileImage)
    local r, c = tileImage.row, tileImage.col
    local x, y = self:computeTileCoords(r, c)

    local squareImage = self.squareImages[r][c]
    local shadedSquareGroup = squareImage.shadedSquareGroup
    if shadedSquareGroup then
        transition.cancel(shadedSquareGroup)
        transition.fadeOut(shadedSquareGroup, {onComplete = function()
            shadedSquareGroup:removeSelf()
        end
        })
        squareImage.shadedSquareGroup = nil
    end

    transition.to(tileImage, {x = x, y = y, rotation = 0, time = 100})
end

function board_class:destroy()
    self.boardContainer:removeSelf()
    self.boardContainer = nil
    self.boardGroup = nil
end

-- Local functions

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