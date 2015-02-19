local rack_class = {}
local rack_class_mt = { __index = rack_class }

local square = require("common.square")
local tile = require("common.tile")
local math = require("math")
local display = require("display")
local common_ui = require("common.common_ui")
local transition = require("transition")
local MAX_TILES = 20


function rack_class.new(gameModel, tileWidth, startY, numPerRow, padding)
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
		padding = padding
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
function rack_class:addTiles(tiles)
	if #tiles + #(self.tileImages) > MAX_TILES then
		native.showAlert( "Too many tiles", "You have too many tiles" )
		return false
	end
	for i = 1, #tiles do
		local grabTile = tiles[i]
		
		self.letters[#(self.letters) + 1] = grabTile.letter
		local tileNum = #(self.letters)
		local x = self:computeTileX(tileNum)
		local y = self:computeTileY(tileNum)

		local newTileImg = tile.draw(grabTile.letter, x, y, self.tileWidth)
		self.tileImages[#(self.tileImages) + 1] = newTileImg

		self.displayGroup:insert(newTileImg)
	end
	return true
end

-- Local functions
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

return rack_class