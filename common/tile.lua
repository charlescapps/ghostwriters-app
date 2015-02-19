local M = {}

local image_sheets = require("globals.image_sheets")
local display = require("display")

local originalTilesImageSheet = image_sheets.getOriginalTilesImageSheet()
local playedTilesImageSheet = image_sheets.getPlayedTilesImageSheet()
local tileTable

-- Function pre-declarations
local createOriginalTile
local createPlayedTile
local buildTileTable

-- Public functions
M.getTileInfo = function(letter)
	return tileTable[letter]
end

M.draw = function(letter, x, y, width)
	local tileInfo = M.getTileInfo(letter)
	if not tileInfo then
		return nil
	end
	local img = display.newImageRect( tileInfo.imageSheet, tileInfo.frameIndex, width, width )
	img.x = x
	img.y = y
	return img
end

-- Local helper functions
createOriginalTile = function(letter, frameIndex)
	return {
		letter = letter,
		imageSheet = originalTilesImageSheet,
		frameIndex = frameIndex
	}
end

createPlayedTile = function(letter, frameIndex)
	return {
		letter = letter,
		imageSheet = playedTilesImageSheet,
		frameIndex = frameIndex
	}
end

buildTileTable = function()
	local tileTable = {}
	-- Build lowercase letters, which represent tiles on the board originally
	for i = 1, 26 do
		local letter = string.char(96 + i)
		tileTable[letter] = createOriginalTile(letter, i)
	end
	-- Build uppercase letters, which represent tiles that were placed, or tiles in the rack
	for i = 1, 26 do
		local letter = string.char(64 + i)
		tileTable[letter] = createPlayedTile(letter, i)
	end
	return tileTable
end


-- Build the tile table
tileTable = buildTileTable()

return M