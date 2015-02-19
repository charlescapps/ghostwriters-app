local M = {}
local graphics = require("graphics")

M.getOriginalTilesImageSheet = function()
	if M.scrabbleTiles then
		print("Scrabble tiles already loaded")
		return M.scrabbleTiles
	end

	local options = {
		width = 50,
		height = 50,
		numFrames = 27,
		sheetContentWidth = 500,
		sheetContentHeight = 150
	}

	M.scrabbleTiles = graphics.newImageSheet("images/scrabble_tiles.png", options)
	return M.scrabbleTiles
end

M.getPlayedTilesImageSheet = function()
	if M.scrabbleTiles then
		print("Scrabble tiles already loaded")
		return M.scrabbleTiles
	end

	local options = {
		width = 50,
		height = 50,
		numFrames = 27,
		sheetContentWidth = 500,
		sheetContentHeight = 150
	}

	M.scrabbleTiles = graphics.newImageSheet("images/scrabble_tiles.png", options)
	return M.scrabbleTiles
end



return M