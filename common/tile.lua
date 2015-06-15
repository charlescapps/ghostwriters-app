local M = {}

local display = require("display")
local common_api = require("common.common_api")

local ghostly_tall = require("spritesheets.ghostly_tall")

local stone_tall = require("spritesheets.stone_tall")

local graphics = require("graphics")

-- Function pre-declarations
local createGhostlyTile
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

-- Spritesheets
M.ghostlySheet = nil
M.stoneSheet = nil
M.rackSheet = nil


M.rackSheetHelper = require("spritesheets.rack_sheet")

-- Public functions
M.getTileInfo = function(letter, isRackTile, boardSize)
    if isRackTile then
        return M.rackTileTable[letter]
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
createGhostlyTile = function(letter, boardSize)
    local helper = ghostly_tall
    if not M.ghostlySheet then
        local imageFile = "spritesheets/ghostly_tall.png"
        M.ghostlySheet = graphics.newImageSheet(imageFile, helper:getSheet())
    end

	return {
		letter = letter,
		imageSheet = M.ghostlySheet,
		frameIndex = helper:getFrameIndex(letter:lower() .. "_ghostly"),
        tileType = M.ORIGINAL_TILE
	}
end

createRackTile = function(letter)
    local helper = M.rackSheetHelper
    if not M.rackSheet then
        local imageFile = "spritesheets/rack_sheet.png"
        M.rackSheet = graphics.newImageSheet(imageFile, helper:getSheet())
    end

    return {
        letter = letter,
        imageSheet = M.rackSheet,
        frameIndex = helper:getFrameIndex(letter:lower() .. "_rack"),
        tileType = M.RACK_TILE
    }
end

createStoneTile = function(letter, boardSize)
    local helper = stone_tall
    if not M.stoneSheet then
        local imageFile = "spritesheets/stone_tall.png"
        M.stoneSheet = graphics.newImageSheet(imageFile, helper:getSheet())
    end

    return {
        letter = letter,
        imageSheet = M.stoneSheet,
        frameIndex = helper:getFrameIndex(letter:lower() .. "_stone"),
        tileType = M.PLAYED_TILE
    }
end

buildTileTable = function(boardSize)
	local tileTable = {}
	-- Build lowercase letters, which represent tiles on the board originally
	for i = 1, 26 do
		local letter = string.char(96 + i)
		tileTable[letter] = createGhostlyTile(letter, boardSize)
    end
    tileTable['?'] = createGhostlyTile('?', boardSize)

	-- Build uppercase letters, which represent tiles that were placed, or tiles in the rack
	for i = 1, 26 do
		local letter = string.char(64 + i)
		tileTable[letter] = createStoneTile(letter, boardSize)
	end
	return tileTable
end

buildRackTileTable = function()
    local tileTable = {}
    -- Rack tiles are always uppercase
    for i = 1, 26 do
        local letter = string.char(64 + i)
        tileTable[letter] = createRackTile(letter)
    end
    tileTable["*"] = createRackTile("*")  -- for wildcard tiles (displayed as "?" in player's rack)
    return tileTable
end


-- Build the tile table
M.tileTable = {}
M.rackTileTable = {}

M.tileTable[common_api.SMALL_SIZE] = buildTileTable(common_api.SMALL_SIZE)
M.tileTable[common_api.MEDIUM_SIZE] = buildTileTable(common_api.MEDIUM_SIZE)
M.tileTable[common_api.LARGE_SIZE] = buildTileTable(common_api.LARGE_SIZE)

M.rackTileTable = buildRackTileTable()

return M