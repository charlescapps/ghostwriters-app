local rack_class = {}
local rack_class_mt = { __index = rack_class }

local common_api = require("common.common_api")
local tile = require("common.tile")
local math = require("math")
local display = require("display")
local transition = require("transition")
local lists = require("common.lists")
local MAX_TILES = 20

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

function rack_class:returnTileImage(tileImage)
	self.displayGroup:insert(tileImage)
	local index = lists.indexOf(self.tileImages, tileImage)
	local x = self:computeTileX(index)
	local y = self:computeTileY(index)
	tileImage.x = x
	tileImage.y = y
    tileImage.width, tileImage.height = self.tileWidth, self.tileWidth
	self.board:removeRackTileFromBoard(tileImage)

end

function rack_class:returnAllTiles()
	local tileImages = self.tileImages
	for i = 1, #tileImages do
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
		    elseif  event.phase == "ended" or event.phase == "cancelled" then
			    -- reset touch focus
	            display.getCurrentStage():setFocus( nil )
	            event.target.isFocus = nil

		        --code executed when the touch lifts off the object
		        local isPlaced = rack.board:addTileFromRack(event.x, event.y, event.target)
		        if not isPlaced then
		        	rack:returnTileImage(event.target)
                end
                return true
		    end
		end
	    return true  --prevents touch propagation to underlying objects
	end
end

return rack_class