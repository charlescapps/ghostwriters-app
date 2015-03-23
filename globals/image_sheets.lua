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
    [common_api.SMALL_SIZE .. "_MINI"] = {
        width = 70,
        height = 70,
        numFrames = 26,
        sheetContentWidth = 700,
        sheetContentHeight = 210
    },
    [common_api.MEDIUM_SIZE] = {
        width = 81,
        height = 81,
        numFrames = 26,
        sheetContentWidth = 810,
        sheetContentHeight = 243
    },
    [common_api.MEDIUM_SIZE .. "_MINI"] = {
        width = 38,
        height = 38,
        numFrames = 26,
        sheetContentWidth = 380,
        sheetContentHeight = 114
    },
    [common_api.LARGE_SIZE] = {
        width = 56,
        height = 56,
        numFrames = 26,
        sheetContentWidth = 560,
        sheetContentHeight = 168
    },
    [common_api.LARGE_SIZE .. "_MINI"] = {
        width = 26,
        height = 26,
        numFrames = 26,
        sheetContentWidth = 260,
        sheetContentHeight = 78
    }
}

local RACK_TILE_OPTIONS = {
    width = 100,
    height = 100,
    numFrames = 26,
    sheetContentWidth = 1000,
    sheetContentHeight = 300
}

local HOT_TILE_IMAGE_SHEETS = {
    [common_api.SMALL_SIZE] = "images/hot_tiles_tall_board.png",
    [common_api.SMALL_SIZE .. "_MINI"] = "images/hot_tiles_tall_board_mini.png",
    [common_api.MEDIUM_SIZE] = "images/hot_tiles_grande_board.png",
    [common_api.MEDIUM_SIZE .. "_MINI"] = "images/hot_tiles_grande_board_mini.png",
    [common_api.LARGE_SIZE] = "images/hot_tiles_venti_board.png",
    [common_api.LARGE_SIZE .. "_MINI"] = "images/hot_tiles_venti_board_mini.png"
}

local STONE_TILE_IMAGE_SHEETS = {
    [common_api.SMALL_SIZE] = "images/stone_tiles_tall_board.png",
    [common_api.SMALL_SIZE .. "_MINI"] = "images/stone_tiles_tall_board_mini.png",
    [common_api.MEDIUM_SIZE] = "images/stone_tiles_grande_board.png",
    [common_api.MEDIUM_SIZE .. "_MINI"] = "images/stone_tiles_grande_board_mini.png",
    [common_api.LARGE_SIZE] = "images/stone_tiles_venti_board.png",
    [common_api.LARGE_SIZE .. "_MINI"] = "images/stone_tiles_venti_board_mini.png"
}

local RACK_TILE_IMAGE_SHEET = "images/rack_tiles.png"

M.hotTiles = {}
M.stoneTiles = {}
M.rackTiles = nil

M.getHotTilesImageSheet = function(boardSize)
	if M.hotTiles[boardSize] then
		return M.hotTiles[boardSize]
	end

	local options = SHEET_OPTIONS[boardSize]
    local imgSheet = HOT_TILE_IMAGE_SHEETS[boardSize]

	M.hotTiles[boardSize] = graphics.newImageSheet(imgSheet, options)
	return M.hotTiles[boardSize]
end

M.getRackTilesImageSheet = function()
    if M.rackTiles then
        return M.rackTiles
    end

    local options = RACK_TILE_OPTIONS
    local imgSheet = RACK_TILE_IMAGE_SHEET

    M.rackTiles = graphics.newImageSheet(imgSheet, options)
    return M.rackTiles
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