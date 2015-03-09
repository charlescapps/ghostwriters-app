local rack_class = {}
local rack_class_mt = { __index = rack_class }

local common_api = require("common.common_api")
local tile = require("common.tile")
local math = require("math")
local display = require("display")
local transition = require("transition")
local easing = require("easing")
local lists = require("common.lists")
local MAX_TILES = 20
local NUM_ROWS = 3

local getTouchListener


function rack_class.new(gameModel, tileWidth, startY, numPerRow, padding, board)
	local rack = gameModel.player1Rack
	local letters = { }

	for i = 1, rack:len() do
		local letter = rack:sub( i, i )
		letters[i] = letter
	end

	print ("Creating new rack with tileWidth=" .. tileWidth)

	local newRack = {
		letters = letters,
		tileWidth = tileWidth,
		startY = startY,
		numPerRow = numPerRow, 
		padding = padding,
		board = board,
        gameModel = gameModel
	}

	newRack = setmetatable( newRack, rack_class_mt )
	newRack:createRackDisplayGroup()
	return newRack
end

function rack_class:isGameFinished()
    return self.gameModel.gameResult ~= common_api.IN_PROGRESS
end

function rack_class:createRackDisplayGroup()
	local group = display.newGroup( )
    group.y = self.startY
    group.x = self.padding

	local letters = self.letters
	local width = self.tileWidth
	local tileImages = {}

    -- Create background texture
    local rackBackground = display.newImageRect("images/rack_bg_texture.png", display.contentWidth, 320)
    rackBackground.x = display.contentWidth / 2 - self.padding
    rackBackground.y = 150
    group:insert(rackBackground)

	for i = 1, #letters do
		local letter = letters[i]
		local x = self:computeTileX(i)
		local y = self:computeTileY(i)
		local img = tile.draw(letter, x, y, width, true)
		img.letter = letter
		print("Letter: " .. letter .. ", img: " .. tostring(img))
		tileImages[#tileImages + 1] = img
        if not self:isGameFinished() then
		    img:addEventListener( "touch", getTouchListener(self) )
        end
		group:insert(img)
    end

	self.displayGroup = group
	self.tileImages = tileImages
	return group
end

-- Returns true on success, false if there aren't enough open slots
function rack_class:addTiles(tilesStr)
	if tilesStr:len() + #(self.tileImages) > MAX_TILES then
		native.showAlert( "Too many tiles", "You have too many tiles", {"Try again"} )
		return false
	end
	for i = 1, tilesStr:len() do
		local grabTile = tilesStr:sub(i, i)
		
		self.letters[#(self.letters) + 1] = grabTile
		local tileNum = #(self.letters)
		local x = self:computeTileX(tileNum)
		local y = self:computeTileY(tileNum)

		local newTileImg = tile.draw(grabTile, x, y, self.tileWidth, true)
		newTileImg.letter = grabTile
		self.tileImages[#(self.tileImages) + 1] = newTileImg

		self.displayGroup:insert(newTileImg)
		newTileImg:addEventListener( "touch", getTouchListener(self) )
	end
	return true
end

function rack_class:computeTileX(i)
	local width = self.tileWidth
	local col = (i - 1) % self.numPerRow
	return math.floor(col * width + width / 2)
end

function rack_class:computeTileY(i)
	local width = self.tileWidth
	local row = math.floor( (i - 1) / self.numPerRow)
	return math.floor(row * width + width / 2)
end

function rack_class:computeRowColFromContentCoords(xContent, yContent)
    local x, y = self.displayGroup:contentToLocal(xContent, yContent)
    local width = self.tileWidth
    local r = math.floor( y / width ) + 1
    local c = math.floor( x / width ) + 1
    return r, c
end

function rack_class:computeIndexFromContentCoords(xContent, yContent)
    local r, c = self:computeRowColFromContentCoords(xContent, yContent)
    print("Computed r, c = " .. r .. ", " .. c .. ", for content coords " .. xContent .. ", " .. yContent)
    if c < 1 or c > self.numPerRow or r < 1 or r > NUM_ROWS then
        return nil
    end

    local index = (r - 1) * self.numPerRow + c

    if index < 1 or index > MAX_TILES then
        return nil
    end

    return index

end

function rack_class:returnTileImage(tileImage)
    if not tileImage then
        return
    end

    local index = lists.indexOf(self.tileImages, tileImage, MAX_TILES)
    if index <= 0 then
        print("Cannot return tile to rack, index is: " .. tostring(index))
        return
    end

    local SPEED = 0.5 -- pixels per millisecond

    local xContent, yContent = tileImage.parent:localToContent(tileImage.x, tileImage.y)
    local xRack, yRack = self.displayGroup:contentToLocal(xContent, yContent)
    tileImage.x, tileImage.y = xRack, yRack

	self.displayGroup:insert(tileImage)

	local x, y = self:computeTileX(index), self:computeTileY(index)
    local dist = math.sqrt((x - xRack)*(x - xRack) + (y - yRack)*(y - yRack))
    local duration = math.floor(dist / SPEED)
    transition.to(tileImage, {x = x, y = y, width = self.tileWidth, height = self.tileWidth,
        time = duration, transition = easing.inOutBack})

	self.board:removeRackTileFromBoard(tileImage)

end

function rack_class:returnAllTiles()
	local tileImages = self.tileImages
	for i = 1, MAX_TILES do
		self:returnTileImage(tileImages[i])
	end
end

function rack_class:returnFloatingTiles()
	if not self.floatingTiles then
		return
	end
	local tileImages = self.tileImages
	for i = 1, #tileImages do
		if tileImages[i].parent == self.floatingTiles then
			self:returnTileImage(tileImages[i])
		end
	end
end

function rack_class:destroy()
    if self.floatingTiles then
        self.floatingTiles:removeSelf()
        self.floatingTiles = nil
    end
    self.displayGroup:removeSelf()
    self.displayGroup = nil
    self.tileImages = nil
end

-- Local functions
getTouchListener = function(rack)
	return function(event)
		if ( event.phase == "began" ) then
			display.getCurrentStage( ):setFocus( event.target )
			event.target.isFocus = true

	        --Insert tile into the root display group so it can move freely.
	        local wasOnBoard = event.target.parent == rack.board.rackTilesGroup

	        -- Create a display group to house the floating tiles
            if not rack.floatingTiles then
            	rack.floatingTiles = display.newGroup()
            	display.currentStage:insert(rack.floatingTiles)
            end
        	rack.floatingTiles:insert(event.target)

	        -- Modify width to account for scale so tile doesn't suddenly become 2x smaller.
	        if wasOnBoard then
	        	local scale = rack.board.boardGroup.xScale
	        	event.target.width = event.target.width * scale
	        	event.target.height = event.target.height * scale
                rack.board:removeRackTileFromBoard(event.target)
	        end
	        event.target.x = event.x
        	event.target.y = event.y	
        	transition.to(event.target, {
        		width = rack.tileWidth,
        		height = rack.tileWidth
        		})
	        return true
	    elseif event.target.isFocus then
	     	if ( event.phase == "moved" ) then
		        --code executed when the touch is moved over the object
		        if event.target.parent then
		        	event.target.x, event.target.y = event.target.parent:contentToLocal( event.x, event.y )
		        else
		        	event.target.x = event.x
		        	event.target.y = event.y
		        end
		        return true
		    elseif event.phase == "ended" or event.phase == "cancelled" then
			    -- reset touch focus
	            display.getCurrentStage():setFocus( nil )
	            event.target.isFocus = nil

		        -- See if tile is above an empty tile on the board, and try to place it there
		        local wasPlacedOnBoard = rack.board:addTileFromRack(event.x, event.y, event.target)
                if wasPlacedOnBoard then
                    return true
                end

                -- See if tile is above a tile in the rack, and try to swap tiles
                local swapIndex = rack:computeIndexFromContentCoords(event.x, event.y)
                local originalIndex = lists.indexOf(rack.tileImages, event.target, MAX_TILES)

                print("swapIndex = " .. tostring(swapIndex) .. ", originalIndex = " .. tostring(originalIndex))

                if swapIndex and originalIndex then
                    rack:swap(originalIndex, swapIndex)
                else
		        	rack:returnTileImage(event.target)
                end
                return true
		    end
		end
	    return true  --prevents touch propagation to underlying objects
	end
end

function rack_class:swap(originalIndex, swapIndex)
    local originalTile = self.tileImages[originalIndex]
    self.tileImages[originalIndex] = self.tileImages[swapIndex]
    self.tileImages[swapIndex] = originalTile

    local swappedTile = self.tileImages[originalIndex]
    if swappedTile then
       local xContent, yContent = swappedTile.parent:localToContent(swappedTile.x, swappedTile.y)
       local index = self:computeIndexFromContentCoords(xContent, yContent)
       if index then
          self:returnTileImage(swappedTile)
       end
    end
    self:returnTileImage(originalTile)
end

return rack_class