local M = {}
local display = require("display")
local graphics = require("graphics")
local common_api = require("common.common_api")
local squares_tall = require("images.squares_tall")
local squares_grande = require("images.squares_grande")
local squares_venti = require("images.squares_venti")

local SHEETS = {
    [common_api.SMALL_SIZE] = graphics.newImageSheet("images/squares_tall.png", squares_tall:getSheet()),
    [common_api.MEDIUM_SIZE] = graphics.newImageSheet("images/squares_grande.png", squares_grande:getSheet()),
    [common_api.LARGE_SIZE] = graphics.newImageSheet("images/squares_venti.png", squares_venti:getSheet())
}

M.NORMAL = { num = "1", letterMult = 1, images = nil }
M.X2 = {num = "2", letterMult = 2, frameIndex = 1}
M.X3 = {num = "3", letterMult = 3, frameIndex = 2}
M.X4 = {num = "4", letterMult = 4, frameIndex = 3}
M.X5 = {num = "5", letterMult = 5, frameIndex = 4}

local borderRgb = {0, 99/256, 54/256}
local backgroundRgb = {0, 189/256, 47/256}

local darkBorderRgb = {0, 29/256, 4/256}
local darkBackgroundRgb = {0, 99/256, 1/256}

local createSquareBackground

M.valueOf = function(str)
	if str == M.NORMAL.num then
		return M.NORMAL
	elseif str == M.X2.num then
		return M.X2
	elseif str == M.X3.num then
		return M.X3
	elseif str == M.X4.num then
		return M.X4
	elseif str == M.X5.num then
		return M.X5
	else
		error("Invalid character for a Square: " .. str)
	end
end

M.draw = function(sqType, x, y, width, boardSize)
	local group = display.newGroup()
	group.x = x
	group.y = y
	local bg = createSquareBackground(0, 0, width)
	group:insert(bg)
	if sqType.frameIndex then
        local sheet = SHEETS[boardSize]
		local img = display.newImageRect(sheet, sqType.frameIndex, width, width)
		group:insert(img)
	end

	group.squareBg = bg

	return group
end

M.drawShadedSquare = function(sqType, x, y, width, boardSize)
    local group = display.newGroup()
    group.x = x
    group.y = y
    local bg = createSquareBackground(0, 0, width, true)
    group:insert(bg)
    if sqType.frameIndex then
        local sheet = SHEETS[boardSize]
        local img = display.newImageRect(sheet, sqType.frameIndex, width, width)
        group:insert(img)
    end

    group.squareBg = bg

    return group
end


createSquareBackground = function(x, y, width, isShaded)
	local myRoundedRect = display.newRoundedRect( x, y, width, width, 12 )
	myRoundedRect.strokeWidth = 5
    if isShaded then
        myRoundedRect:setFillColor( darkBackgroundRgb[1], darkBackgroundRgb[2], darkBackgroundRgb[3] )
        myRoundedRect:setStrokeColor( darkBorderRgb[1], darkBorderRgb[2], darkBorderRgb[3] )
    else
	    myRoundedRect:setFillColor( backgroundRgb[1], backgroundRgb[2], backgroundRgb[3] )
	    myRoundedRect:setStrokeColor( borderRgb[1], borderRgb[2], borderRgb[3] )
    end
	return myRoundedRect
end

return M