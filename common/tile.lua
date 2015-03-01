local M = {}

local image_sheets = require("globals.image_sheets")
local display = require("display")

local originalTilesImageSheet = image_sheets.getOriginalTilesImageSheet()
local rackTilesImageSheet = image_sheets.getRackTilesImageSheet()
local playedTilesImageSheet = image_sheets.getPlayedTilesImageSheet()
local tileTable
local rackTileTable

-- Function pre-declarations
local createOriginalTile
local createRackTile
local createPlayedTile
local buildTileTable
local buildRackTileTable

-- Constants
M.emptyTile = "_"

-- Public functions
M.getTileInfo = function(letter, isRackTile)
    if isRackTile then
        return rackTileTable[letter]
    else
	    return tileTable[letter]
    end
end

M.draw = function(letter, x, y, width, isRackTile)
	local tileInfo = M.getTileInfo(letter, isRackTile)
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

createRackTile = function(letter, frameIndex)
    return {
        letter = letter,
        imageSheet = rackTilesImageSheet,
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

buildRackTileTable = function()
    local tileTable = {}
    -- Rack tiles are always uppercase
    for i = 1, 26 do
        local letter = string.char(64 + i)
        tileTable[letter] = createRackTile(letter, i)
    end
    return tileTable
end


-- Build the tile table
tileTable = buildTileTable()
rackTileTable = buildRackTileTable()

return M