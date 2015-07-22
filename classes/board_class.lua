local board_class = {}
local board_class_mt = { __index = board_class }

local board_helpers = require("common.board_helpers")
local square = require("common.square")
local tile = require("common.tile")
local points_bubble_class = require("classes.points_bubble_class")
local math = require("math")
local display = require("display")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local transition = require("transition")
local table = require("table")
local letter_picker = require("classes.letter_picker")
local game_helpers = require("common.game_helpers")

local lists = require("common.lists")

-- Constants
local APPLY_MOVE_TAG = "apply_move_tag"
local DRAG_BOARD_TAG = "drag_board_tag"
local TILE_PADDING = 2

-- Pre-declaration of functions

local isConnected

function board_class.new(gameModel, authUser, startX, startY, width, padding, onGrabTiles)
	local N = gameModel.numRows
	local squares = board_helpers.parseSquares(gameModel["squares"], N)
	local tiles = board_helpers.parseTiles(gameModel["tiles"], N)
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
        tileWidth = width / N,
        drawTileWidth = width / N - 2 * TILE_PADDING,
        padding = padding,
		onGrabTiles = onGrabTiles,
		rackTileImages = rackTileImages,
        gameModel = gameModel,
        authUser = authUser
    }

	newBoard = setmetatable( newBoard, board_class_mt )

    newBoard.pointsBubble = points_bubble_class.new(newBoard)

    newBoard:createBoardContainer()
    return newBoard
end

-- Board class Methods --

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

function board_class:isGameFinished()
    return self.gameModel.gameResult ~= common_api.IN_PROGRESS and self.gameModel.gameResult ~= common_api.OFFERED
end

function board_class:computeTileCoords(r, c)
    local tileWidth = self.tileWidth
    local x = math.floor((c - 1) * tileWidth + tileWidth / 2 - self.width / 2)
    local y = math.floor((r - 1) * tileWidth + tileWidth / 2 - self.width / 2)
    return x, y
end

function board_class:createSquaresGroup(width)
	local squaresGroup = display.newGroup()
	local N = self.N
	local squares = self.squares
	local width = self.width
	local squareImages = {}
	for i = 1, N do
		squareImages[i] = {}
	end

	for i = 1, N do
		for j = 1, N do
			local s = squares[i][j]
			local x, y = self:computeTileCoords(i, j)
			local squareGroup = square.draw(s, x, y, self.tileWidth, self.gameModel.boardSize)
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
	local tileWidth = self.tileWidth
	local x = math.floor((col - 0.5) * tileWidth - self.width / 2)
	local y = math.floor((row - 0.5) * tileWidth - self.width / 2)
	return x, y
end

function board_class:createTilesGroup()
	local tilesGroup = display.newGroup()
	local N = self.N
	local width = self.width
	local tiles = self.tiles

	local tileImages = {}
	for i = 1, N do
		tileImages[#tileImages + 1] = {}
	end

	for i = 1, N do
		for j = 1, N do
			local t = tiles[i][j]
			local x, y = self:computeTileCoords(i, j)
			local img = tile.draw(t, x, y, self.drawTileWidth, false, self.gameModel.boardSize)
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
           display.getCurrentStage():setFocus(event.target)
           self.boardGroupStartX, self.boardGroupStartY = self.boardGroup.x, self.boardGroup.y
        elseif event.phase == "moved" then
            if not self.boardGroupStartX or not self.boardGroupStartY then
                return
            end
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
        return true
    end
end

function board_class:getTilesGroupTouchListener()
    return function(event)
        if self.interactionDisabled then
            return true
        end
        if event.phase == "began" then
            local myTile = self:tileForCoords(event.x, event.y)
            -- If the touch event isn't over a grabbable tile
            if myTile == nil or
               myTile.tileType ~= tile.ORIGINAL_TILE or
               not game_helpers.isPlayerTurn(self.gameModel, self.authUser) then
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

            self:dragZoomedBoardOnTouch(event)

            -- If this is another moved event on the same tile, then just return.
            local lastTile = self.grabbed and self.grabbed[#(self.grabbed)]
            if lastTile and lastTile.row == myTile.row and lastTile.col == myTile.col then
                return true
            end
            if table.indexOf(self.grabbed, myTile) then
               return true
            end
            if myTile.tileType ~= tile.ORIGINAL_TILE then
                print ("User grabbed a non-grabbable tile, cancelling grab: " .. myTile.letter)
                self:cancelDragging()
                self:cancelGrab()
                return true
            end

            self:addGrabEffect(myTile)
            self.grabbed[#(self.grabbed) + 1] = myTile

        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            self:cancelDragging()
            if not self.isGrabbing or not isConnected(self.grabbed) then
                self:cancelGrab()
                return true
            end
            self.onGrabTiles(self.grabbed)
        end
        return true
    end
end

function board_class:dragZoomedBoardOnTouch(event)
    if not self.isZoomed then
        return
    end

    local xLocal, yLocal = self.boardContainer:contentToLocal(event.x, event.y)
    local width, padding = self.width, self.padding
    local ZOOM_MARGIN = 150
    local xDelta, yDelta = 0, 0
    local xStart, yStart = self.boardGroup.x, self.boardGroup.y

    local scale = self:getZoomScale()

    if math.abs(yLocal) < width / 2 + padding then
        if math.abs(xLocal - width / 2) < ZOOM_MARGIN then
            xDelta = -xStart - scale * width / 2
        elseif math.abs(xLocal + width / 2) < ZOOM_MARGIN then
            xDelta = -xStart + scale * width / 2
        end
    end
    if xDelta == 0 and math.abs(xLocal) < width / 2 + padding then
        if math.abs(yLocal - width / 2) < ZOOM_MARGIN then
            yDelta = -yStart - scale * width / 2
        elseif math.abs(yLocal + width / 2) < ZOOM_MARGIN then
            yDelta = -yStart + scale * width / 2
        end
    end


    if xDelta == 0 and yDelta == 0 then
        self:cancelDragging()
        return
    elseif self.isDragging then
        return
    end

    local function onComplete()
        self.isDragging = false
    end
    local xTarget, yTarget = self:restrictX(xStart + xDelta, scale), self:restrictX(yStart + yDelta, scale)
    transition.to(self.boardGroup, {
        x = xTarget,
        y = yTarget,
        tag = DRAG_BOARD_TAG,
        time = 5000 * (math.abs(xTarget - xStart) + math.abs(yTarget - yStart)) / (scale * width),
        onComplete = onComplete,
        onCancel = onComplete
    })
    self.isDragging = true
end

function board_class:cancelDragging()
    self.isDragging = false
    transition.cancel(DRAG_BOARD_TAG)
end

function board_class:rowColForCoords(xContent, yContent)
    local x, y = self.tilesGroup:contentToLocal(xContent, yContent)
    local width = self.width
    local tileWidth = self.tileWidth
    local c = math.floor((x + width / 2) / tileWidth + 1)
    local r = math.floor((y + width / 2) / tileWidth + 1)
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

function board_class:getBoardTapListener()
	return function(event)
        if self.interactionDisabled then
            return true
        end
		if not self.boardGroup then
			print("Board has no self.boardGroup. Cannot process tap event.")
			return true
		end

		if event.numTaps == 2 then
            local zoomScale = self:getZoomScale()
			self:toggleZoom(zoomScale, event.x - self.boardGroup.x, event.y - self.boardGroup.y)
		else
            return true
		end
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
    local boardTexture = display.newImageRect("images/board_bg_texture.png", width + padding, width + padding)

	self.boardGroup = boardGroup
    self.tilesGroup = tilesGroup
	self.rackTilesGroup = rackTilesGroup
    self.boardContainer = boardContainer
    self.boardTexture = boardTexture

    boardGroup:insert(boardTexture)
    boardGroup:insert(squaresGroup)
    boardGroup:insert(tilesGroup)
    boardGroup:insert(rackTilesGroup)
    boardGroup:addEventListener("tap", self:getBoardTapListener())

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

function board_class:cancelGrab()
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

function board_class:addTileFromRack(contentX, contentY, tileImage, rack)
	local letter = tileImage.letter
	local squareImage = self:squareForCoords(contentX, contentY)
	if not squareImage or not letter then
		return false
    end

    if self.interactionDisabled then
        return false
    end

    if letter == "^" then
        game_helpers.promptScryTileAction(self, rack, tileImage)
        return true
    end

	local row, col = squareImage.row, squareImage.col
    if self.tileImages[row][col] or self.rackTileImages[row][col] then
        print("Tile already present at (" .. tostring(row) .. ", " .. tostring(col) .. ")")
        return false
    end
	print ("Inserting tile at row = " .. tostring(row) .. ", col = " .. tostring(col))
    transition.cancel(tileImage)  -- cancel outstanding animations on the tile.
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
		width = squareImage.squareBg.width - 2 * TILE_PADDING,
		height = squareImage.squareBg.height - 2 * TILE_PADDING,
        time = 250,
		onComplete = function(event)
			print("Finished adding letter " .. letter .. " to the board")
            if letter == "*" then
                -- Ask the user to choose the letter
                self:promptUserToChooseWildcardLetter(tileImage, squareImage)
            else
                self.pointsBubble:drawPointsBubble()
            end
		end
		})

	return true

end

function board_class:promptUserToChooseWildcardLetter(tileImage, squareImage)
    local function onSelectLetter(letter)
        tileImage.chosenLetter = letter
        tileImage.chosenLetterImage = tile.draw(letter, tileImage.x, tileImage.y, tileImage.width, true, self.gameModel.boardSize)
        self.rackTilesGroup:insert(tileImage.chosenLetterImage)
        tileImage.chosenLetterImage:toFront()
        self.pointsBubble:drawPointsBubble()
    end

    local letterPicker = letter_picker.new(onSelectLetter)
    letterPicker:render()
    letterPicker:show()
end

function board_class:removeRackTileFromBoard(tileImage)
    local row, col = tileImage.row, tileImage.col
	if row and col then
        local rackTile = self.rackTileImages[row][col]
		self.rackTileImages[row][col] = nil
        if rackTile then
            self.pointsBubble:drawPointsBubble()
            if rackTile.chosenLetterImage and rackTile.chosenLetterImage.removeSelf then
                rackTile.chosenLetterImage:removeSelf()
                rackTile.chosenLetter, rackTile.chosenLetterImage = nil, nil
            end
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
	local moveJson =  {
		letters = letters:upper(),
		start = { r = startR - 1, c = startC - 1 },
		dir = dir,
		tiles = rackTileLetters,
		moveType = common_api.PLAY_TILES
    }

    local points = self.pointsBubble:computePoints(moveJson)
    moveJson.points = points
    return moveJson
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
		return self:getLettersInRange(startR, startC, endR, endC, true), startR, startC, "E"
	elseif (#orderedTiles == 1 and (row > 1 and tileImages[row - 1][col] or row < N and tileImages[row + 1][col])) or 
			#orderedTiles > 1 and orderedTiles[1].row < orderedTiles[2].row then -- South direction
		local startR, startC = self:getLastOccupied(row, col, {-1, 0})
		local endR, endC = self:getLastOccupied(row, col, {1, 0})
		return self:getLettersInRange(startR, startC, endR, endC, true), startR, startC, "S"
	else 
		return {errorMsg = "Invalid play"}
	end

end

function board_class:getLettersInRange(startR, startC, endR, endC, includeRackTiles)
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
			elseif includeRackTiles and rackTileImages[r][j] then
                local rackLetter = rackTileImages[r][j].letter
                if rackLetter == "*" then
                    rackLetter = rackTileImages[r][j].chosenLetter
                end
				letters = letters .. rackLetter
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
			elseif includeRackTiles and rackTileImages[i][c] then
                local rackLetter = rackTileImages[i][c].letter
                if rackLetter == "*" then
                    rackLetter = rackTileImages[i][c].chosenLetter
                end
				letters = letters .. rackLetter
			end
		end
		return letters
	else
		if tileImages[startR][startC] then
			return tileImages[startR][startC].letter
		elseif not includeRackTiles then
            return ""
        else
			local rackLetter = rackTileImages[startR][startC].letter
            if rackLetter == "*" then
                rackLetter = rackTileImages[startR][startC].chosenLetter
            end
            return rackLetter
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

-- Returns the start image and end image
function board_class:getWordCenteredAt(row, col, dir)
    if row < 1 or row > self.N or
            col < 1 or col > self.N or
            self.tileImages[row][col] == nil then
        return nil
    end

    local neg = {-dir[1], -dir[2]}
    local startR, startC = self:getLastOccupied(row, col, neg)
    local endR, endC = self:getLastOccupied(row, col, dir)
    if startR == endR and startC == endC then
        return nil
    end
    return { startR, startC, endR, endC }
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
			if rackTileImages[i][j] and not lists.indexOf(orderedTiles, rackTileImages[i][j]) then
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

    -- Remove any pending transitions
    transition.cancel(APPLY_MOVE_TAG)

    for i = 1, self.N do
        for j = 1, self.N do
            local tileImg = self.tileImages[i][j]
            if tileImg then
                transition.cancel(tileImg)
            end
            if self.rackTileImages then
                local rackImg = self.rackTileImages[i][j]
                if rackImg then
                    transition.cancel(rackImg)
                end
            end
            local squareImg = self.squareImages[i][j]
            if squareImg then
                transition.cancel(squareImg)
            end
            local shadeSquareGroup = squareImg.shadedSquareGroup
            if shadeSquareGroup then
                transition.cancel(shadeSquareGroup)
            end
        end
    end

    self.boardContainer:removeSelf()
    self.pointsBubble:destroy()
    self.pointsBubble = nil
    self.boardContainer = nil
    self.boardGroup = nil
end

function board_class:applyMove(move, rack, isCurrentUser, onComplete)
    if move.moveType == common_api.PASS or move.moveType == common_api.RESIGN then
        print("Board applying PASS or RESIGN move, doing nothing...")
        if onComplete then
            onComplete()
        end
    elseif move.moveType == common_api.PLAY_TILES then
        self:applyPlayTilesMove(move.tiles, move.letters, move.start.r + 1, move.start.c + 1, move.dir, onComplete)
    elseif move.moveType == common_api.GRAB_TILES then
        if isCurrentUser then
            self:applyCurrentUserGrabTilesMove(rack, move.letters, move.start.r + 1, move.start.c + 1, move.dir, onComplete)
        else
            self:applyOpponentGrabTilesMove(move.letters, move.start.r + 1, move.start.c + 1, move.dir, onComplete)
        end
    end
end

function board_class:go(r, c, dir, distance)
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

function board_class:applyPlayTilesMove(tiles, letters, startR, startC, dir, onComplete)
    local tileIndex = 1
    local r, c = startR, startC
    local firstTile = true
    for i = 0, letters:len() - 1 do
        if r < 1 or c < 1 or r > self.N or c > self.N then
            print("Error - invalid row or column reached in applyPlayTilesMoves: " .. tostring(r) .. ", " .. tostring(c))
            return
        end
        local myTile = self.tiles[r][c]
        local x, y = self:computeTileCoords(r, c)

        if myTile == tile.emptyTile and tileIndex <= tiles:len() then
           local letter = letters:sub(i + 1, i + 1)

           local newTileImg = tile.draw(letter:upper(), x, y, self.drawTileWidth, false, self.gameModel.boardSize)
           newTileImg.alpha = 0;
           newTileImg.letter = letter
           self.tilesGroup:insert(newTileImg)
           self.tiles[r][c] = letter
           self.tileImages[r][c] = newTileImg
           if firstTile then
                firstTile = false
                transition.fadeIn(newTileImg, { tag = APPLY_MOVE_TAG, time = 2000, onComplete = onComplete })
           else
                transition.fadeIn(newTileImg, { tag = APPLY_MOVE_TAG, time = 2000 })
           end
           tileIndex = tileIndex + 1
           if self.rackTileImages and self.rackTileImages[r][c] then
               local rackTile = self.rackTileImages[r][c]
               self.rackTileImages[r][c] = nil
               local function onComplete(obj)
                   if obj and obj.removeSelf then
                       obj:removeSelf()
                   end
               end

               transition.fadeOut(rackTile, {
                   tag = APPLY_MOVE_TAG,
                   time = 2000,
                   onComplete = onComplete,
                   onCancel = onComplete
               })

               if rackTile.letter == "*" and rackTile.chosenLetterImage then
                   transition.fadeOut(rackTile.chosenLetterImage, {
                       tag = APPLY_MOVE_TAG,
                       time = 2000,
                       onComplete = onComplete,
                       onCancel = onComplete
                   })
               end
           end
        else
            -- If the existing tile was lowercase, then change the tile to a stone tile
            if myTile:upper() ~= myTile then
                local myTileImg = self.tileImages[r][c]
                local stoneTileImg = tile.draw(myTile:upper(), x, y, self.drawTileWidth, false, self.gameModel.boardSize)
                stoneTileImg.alpha = 0
                self.tilesGroup:insert(stoneTileImg)
                self.tileImages[r][c] = stoneTileImg
                stoneTileImg.replaceTile = myTileImg
                transition.fadeIn(stoneTileImg, { tag = APPLY_MOVE_TAG, time = 2000, onComplete = function(obj)
                    if obj.replaceTile then
                        obj.replaceTile:removeSelf()
                    end
                end })
            end
        end

        r, c = self:go(r, c, dir)
    end
end

function board_class:applyOpponentGrabTilesMove(letters, startR, startC, dir, onComplete)
    local isFirstTile = true
    for i = 0, letters:len() - 1 do
       local r, c = self:go(startR, startC, dir, i)
       local tileImg = self.tileImages[r][c]
       self.tileImages[r][c] = nil
       self.tiles[r][c] = tile.emptyTile
       if tileImg then
           if isFirstTile then
               isFirstTile = false
               transition.fadeOut(tileImg, { tag = APPLY_MOVE_TAG, time = 2000, onComplete = onComplete })
           else
               transition.fadeOut(tileImg, { tag = APPLY_MOVE_TAG, time = 2000 })
           end
       end
    end
end

function board_class:fadeOutGrabbedTile(r, c, rack, onComplete)
    local tileImg = self.tileImages[r][c]
    rack:addTileImage(tileImg, onComplete)
    self.tileImages[r][c] = nil
    self.tiles[r][c] = tile.emptyTile

    local squareImg = self.squareImages[r][c]
    if squareImg and squareImg.shadedSquareGroup then
       transition.fadeOut(squareImg.shadedSquareGroup, { tag = APPLY_MOVE_TAG, time = 2000 })
    end
end

function board_class:applyCurrentUserGrabTilesMove(rack, letters, startR, startC, dir, onComplete)
    local isFirstTile = true

    for i = 0, letters:len() - 1 do
       local r, c = self:go(startR, startC, dir, i)
       if isFirstTile then
           isFirstTile = false
           self:fadeOutGrabbedTile(r, c, rack, onComplete)
       else
           self:fadeOutGrabbedTile(r, c, rack)
       end
    end
end

-- Local functions

isConnected = function(tiles)
	if #tiles <= 1 then
		return true
	end

	local t1 = tiles[1] 
	local t2 = tiles[2]
	local vec = { t2.row - t1.row, t2.col - t1.col }

	if not board_helpers.isUnitVector(vec) then
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



return board_class