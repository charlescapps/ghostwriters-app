local M = {}
local graphics = require("graphics")
local common_api = require("common.common_api")

local SHEET_OPTIONS = {
    [common_api.SMALL_SIZE] = {
        width = 146,
        height = 146,
        numFrames = 26,
        sheetContentWidth = 1460,
        sheetContentHeight = 438
    },
    [common_api.MEDIUM_SIZE] = {
        width = 81,
        height = 81,
        numFrames = 26,
        sheetContentWidth = 810,
        sheetContentHeight = 243
    },
    [common_api.LARGE_SIZE] = {
        width = 56,
        height = 56,
        numFrames = 26,
        sheetContentWidth = 560,
        sheetContentHeight = 168
    }
}

local HOT_TILE_IMAGE_SHEETS = {
    [common_api.SMALL_SIZE] = "images/hot_tiles_tall_board.png",
    [common_api.MEDIUM_SIZE] = "images/hot_tiles_grande_board.png",
    [common_api.LARGE_SIZE] = "images/hot_tiles_venti_board.png"
}

local RACK_TILE_IMAGE_SHEETS = {
    [common_api.SMALL_SIZE] = "images/rack_tiles_tall_board.png",
    [common_api.MEDIUM_SIZE] = "images/rack_tiles_grande_board.png",
    [common_api.LARGE_SIZE] = "images/rack_tiles_venti_board.png"
}

local STONE_TILE_IMAGE_SHEETS = {
    [common_api.SMALL_SIZE] = "images/stone_tiles_tall_board.png",
    [common_api.MEDIUM_SIZE] = "images/stone_tiles_grande_board.png",
    [common_api.LARGE_SIZE] = "images/stone_tiles_venti_board.png"
}

M.hotTiles = {}
M.rackTiles = {}
M.stoneTiles = {}

M.getHotTilesImageSheet = function(boardSize)
	if M.hotTiles[boardSize] then
		return M.hotTiles[boardSize]
	end

	local options = SHEET_OPTIONS[boardSize]
    local imgSheet = HOT_TILE_IMAGE_SHEETS[boardSize]

	M.hotTiles[boardSize] = graphics.newImageSheet(imgSheet, options)
	return M.hotTiles[boardSize]
end

M.getRackTilesImageSheet = function(boardSize)
    if M.rackTiles[boardSize] then
        return M.rackTiles[boardSize]
    end

    local options = SHEET_OPTIONS[boardSize]
    local imgSheet = RACK_TILE_IMAGE_SHEETS[boardSize]

    M.rackTiles[boardSize] = graphics.newImageSheet(imgSheet, options)
    return M.rackTiles[boardSize]
end

M.getStoneTilesImageSheet = function(boardSize)
    if M.stoneTiles[boardSize] then
        return M.stoneTiles[boardSize]
    end

    local options = SHEET_OPTIONS[boardSize]
    local imgSheet = STONE_TILE_IMAGE_SHEETS[boardSize]

    M.stoneTiles[boardSize] = graphics.newImageSheet(imgSheet, options)
    return M.stoneTiles[boardSize]
end

return M