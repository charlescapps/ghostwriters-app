local M = {}

local image_sheets = require("globals.image_sheets")
local display = require("display")
local common_api = require("common.common_api")

-- Function pre-declarations
local createHotTile
local createRackTile
local createStoneTile
local buildTileTable
local buildRackTileTable

-- Constants
M.emptyTile = "_"

-- Tile types
M.ORIGINAL_TILE = "ORIGINAL_TILE"
M.PLAYED_TILE = "PLAYED_TILE"
M.EMPTY_TILE = "EMPTY_TILE"
M.RACK_TILE = "RACK_TILE"

-- Public functions
M.getTileInfo = function(letter, isRackTile, boardSize)
    if isRackTile then
        return M.rackTileTable[boardSize][letter]
    else
	    return M.tileTable[boardSize][letter]
    end
end

M.draw = function(letter, x, y, width, isRackTile, boardSize)
	local tileInfo = M.getTileInfo(letter, isRackTile, boardSize)
	if not tileInfo then
		return nil
	end
	local img = display.newImageRect( tileInfo.imageSheet, tileInfo.frameIndex, width, width )
	img.x = x
	img.y = y
    img.tileType = tileInfo.tileType
	return img
end

-- Local helper functions
createHotTile = function(letter, frameIndex, boardSize)
	return {
		letter = letter,
		imageSheet = image_sheets.getHotTilesImageSheet(boardSize),
		frameIndex = frameIndex,
        tileType = M.ORIGINAL_TILE
	}
end

createRackTile = function(letter, frameIndex, boardSize)
    return {
        letter = letter,
        imageSheet = image_sheets.getRackTilesImageSheet(boardSize),
        frameIndex = frameIndex,
        tileType = M.RACK_TILE
    }
end

createStoneTile = function(letter, frameIndex, boardSize)
	return {
		letter = letter,
		imageSheet = image_sheets.getStoneTilesImageSheet(boardSize),
		frameIndex = frameIndex,
        tileType = M.PLAYED_TILE
	}
end

buildTileTable = function(boardSize)
	local tileTable = {}
	-- Build lowercase letters, which represent tiles on the board originally
	for i = 1, 26 do
		local letter = string.char(96 + i)
		tileTable[letter] = createHotTile(letter, i, boardSize)
	end
	-- Build uppercase letters, which represent tiles that were placed, or tiles in the rack
	for i = 1, 26 do
		local letter = string.char(64 + i)
		tileTable[letter] = createStoneTile(letter, i, boardSize)
	end
	return tileTable
end

buildRackTileTable = function(boardSize)
    local tileTable = {}
    -- Rack tiles are always uppercase
    for i = 1, 26 do
        local letter = string.char(64 + i)
        tileTable[letter] = createRackTile(letter, i, boardSize)
    end
    return tileTable
end


-- Build the tile table
M.tileTable = {}
M.rackTileTable = {}

M.tileTable[common_api.SMALL_SIZE] = buildTileTable(common_api.SMALL_SIZE)
M.tileTable[common_api.SMALL_SIZE .. "_MINI"] = buildTileTable(common_api.SMALL_SIZE .. "_MINI")
M.tileTable[common_api.MEDIUM_SIZE] = buildTileTable(common_api.MEDIUM_SIZE)
M.tileTable[common_api.MEDIUM_SIZE .. "_MINI"] = buildTileTable(common_api.MEDIUM_SIZE .. "_MINI")
M.tileTable[common_api.LARGE_SIZE] = buildTileTable(common_api.LARGE_SIZE)
M.tileTable[common_api.LARGE_SIZE .. "_MINI"] = buildTileTable(common_api.LARGE_SIZE .. "_MINI")

M.rackTileTable[common_api.SMALL_SIZE] = buildRackTileTable(common_api.SMALL_SIZE)
M.rackTileTable[common_api.MEDIUM_SIZE] = buildRackTileTable(common_api.MEDIUM_SIZE)
M.rackTileTable[common_api.LARGE_SIZE] = buildRackTileTable(common_api.LARGE_SIZE)

return M