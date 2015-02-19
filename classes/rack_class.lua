local rack_class = {}
local rack_class_mt = { __index = rack_class }

local square = require("common.square")
local tile = require("common.tile")
local math = require("math")
local display = require("display")
local common_ui = require("common.common_ui")
local transition = require("transition")


function rack_class.new(gameModel, tileWidth, startY, numPerRow, padding)
	local rack = "ABCDEFGHIJ" -- gameModel.player1Rack
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

	return setmetatable( newRack, rack_class_mt )
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
		local row = math.floor( (i - 1) / numPerRow)
		local col = (i - 1) % numPerRow
		local x = math.floor(padding + col * width + width / 2)
		local y = math.floor(startY + row * width + width / 2)
		local img = tile.draw(letter, x, y, width)
		print("Letter: " .. letter .. ", img: " .. tostring(img))
		tileImages[#tileImages + 1] = img
		group:insert(img)
	end

	self.tileImages = tileImages
	return group
end


return rack_class