local M = {}

local display = require("display")
local common_api = require("common.common_api")

local ghostly_tall = require("spritesheets.ghostly_tall")
local ghostly_grande = require("spritesheets.ghostly_grande")
local ghostly_venti = require("spritesheets.ghostly_venti")

local stone_tall = require("spritesheets.stone_tall")
local stone_grande = require("spritesheets.stone_grande")
local stone_venti = require("spritesheets.stone_venti")

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
M.ghostlySheets = {}
M.stoneSheets = {}
M.rackSheet = nil

M.ghostlySheetHelpers = {
    [common_api.SMALL_SIZE] = ghostly_tall,
    [common_api.MEDIUM_SIZE] = ghostly_grande,
    [common_api.LARGE_SIZE] = ghostly_venti
}
M.stoneSheetHelpers = {
    [common_api.SMALL_SIZE] = stone_tall,
    [common_api.MEDIUM_SIZE] = stone_grande,
    [common_api.LARGE_SIZE] = stone_venti
}
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
    local helper = M.ghostlySheetHelpers[boardSize]
    if not M.ghostlySheets[boardSize] then
        local imageFile = "spritesheets/ghostly_" .. boardSize:lower() .. ".png"
        M.ghostlySheets[boardSize] = graphics.newImageSheet(imageFile, helper:getSheet())
    end

	return {
		letter = letter,
		imageSheet = M.ghostlySheets[boardSize],
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
    local helper = M.stoneSheetHelpers[boardSize]
    if not M.stoneSheets[boardSize] then
        local imageFile = "spritesheets/stone_" .. boardSize:lower() .. ".png"
        M.stoneSheets[boardSize] = graphics.newImageSheet(imageFile, helper:getSheet())
    end

    return {
        letter = letter,
        imageSheet = M.stoneSheets[boardSize],
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
        tileTable[letter] = createRackTile(letter, i)
    end
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