local rack_class = {}
local rack_class_mt = { __index = rack_class }

local square = require("common.square")
local tile = require("common.tile")
local math = require("math")
local display = require("display")
local common_ui = require("common.common_ui")
local transition = require("transition")
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
		board = board
	}

	newRack = setmetatable( newRack, rack_class_mt )
	newRack:createRackDisplayGroup()
	return newRack
end

function rack_class:createRackDisplayGroup()
	local group = display.newGroup( )
	local letters = self.letters
	local startY = self.startY
	local width = self.tileWidth
	local numPerRow = self.numPerRow
	local padding = self.padding
	local tileImages = {}

	for i = 1, #letters do
		local letter = letters[i]
		local x = self:computeTileX(i)
		local y = self:computeTileY(i)
		local img = tile.draw(letter, x, y, width)
		img.letter = letter
		print("Letter: " .. letter .. ", img: " .. tostring(img))
		tileImages[#tileImages + 1] = img
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

		local newTileImg = tile.draw(grabTile, x, y, self.tileWidth)
		self.tileImages[#(self.tileImages) + 1] = newTileImg

		self.displayGroup:insert(newTileImg)
		newTileImg:addEventListener( "touch", getTouchListener(self) )
	end
	return true
end

function rack_class:computeTileX(i)
	local width = self.tileWidth
	local col = (i - 1) % self.numPerRow
	return math.floor(self.padding + col * width + width / 2)
end

function rack_class:computeTileY(i)
	local width = self.tileWidth
	local row = math.floor( (i - 1) / self.numPerRow)
	return math.floor(self.startY + row * width + width / 2)
end

function rack_class:clearDraggedTile()
	self.draggedTile.x = self.draggedTileX
	self.draggedTile.y = self.draggedTileY
	self.draggedTile = nil
	self.draggedTileX = nil
	self.draggedTileY = nil
end

-- Local functions
local getTouchListener = function(rack)
	return function(event)
		if ( event.phase == "began" ) then
	        --code executed when the rack tile is first touched
	        rack.draggedTileX = event.target.x
	        rack.draggedTileY = event.target.y
	        rack.draggedTile = event.target
	        return true
	    elseif ( event.phase == "moved" ) then
	        --code executed when the touch is moved over the object
	        print("moved to x = " .. event.x .. ", y = " .. event.y)
	        event.target.x = event.x
	        event.target.y = event.y
	        return true
	    elseif ( event.phase == "ended" ) then
	        --code executed when the touch lifts off the object
	        print( "touch ended on object "..tostring(event.target) )
	    elseif (event.phase == "cancelled") then
	    	rack:clearDraggedTile()
	    end
	    return true  --prevents touch propagation to underlying objects
	end
end

return rack_class