local M = {}
local graphics = require("graphics")

M.getOriginalTilesImageSheet = function()
	if M.originalTiles then
		print("Scrabble tiles already loaded")
		return M.originalTiles
	end

	local options = {
		width = 50,
		height = 50,
		numFrames = 27,
		sheetContentWidth = 500,
		sheetContentHeight = 150
	}

	M.originalTiles = graphics.newImageSheet("images/scrabble_tiles_hot.png", options)
	return M.originalTiles
end

M.getRackTilesImageSheet = function()
    if M.rackTiles then
        print("Rack tiles sprite sheet already loaded")
        return M.rackTiles
    end

    local options = {
        width = 50,
        height = 50,
        numFrames = 27,
        sheetContentWidth = 500,
        sheetContentHeight = 150
    }

    M.rackTiles = graphics.newImageSheet("images/scrabble_tiles.png", options)
    return M.rackTiles
end

M.getPlayedTilesImageSheet = function()
	if M.playedTiles then
		print("Scrabble tiles already loaded")
		return M.playedTiles
	end

	local options = {
		width = 50,
		height = 50,
		numFrames = 27,
		sheetContentWidth = 500,
		sheetContentHeight = 150
	}

	M.playedTiles = graphics.newImageSheet("images/scrabble_tiles_stone.png", options)
	return M.playedTiles
end



return M