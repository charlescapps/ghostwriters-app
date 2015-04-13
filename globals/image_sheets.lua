local M = {}
local graphics = require("graphics")
local common_api = require("common.common_api")


local RACK_TILE_OPTIONS = {
    width = 100,
    height = 100,
    numFrames = 26,
    sheetContentWidth = 1000,
    sheetContentHeight = 300
}

local RACK_TILE_IMAGE_SHEET = "images/rack_tiles.png"

M.hotTiles = {}
M.stoneTiles = {}
M.rackTiles = nil


M.getRackTilesImageSheet = function()
    if M.rackTiles then
        return M.rackTiles
    end

    local options = RACK_TILE_OPTIONS
    local imgSheet = RACK_TILE_IMAGE_SHEET

    M.rackTiles = graphics.newImageSheet(imgSheet, options)
    return M.rackTiles
end

return M