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

local SHEET_MODULES = {
    [common_api.SMALL_SIZE] = squares_tall,
    [common_api.MEDIUM_SIZE] = squares_grande,
    [common_api.LARGE_SIZE] = squares_venti
}

M.NORMAL = { num = "1", letterMult = 1, frameName = nil }
M.X2 = {num = "2", letterMult = 2, frameName = "X2"}
M.X3 = {num = "3", letterMult = 3, frameName = "X3"}
M.X4 = {num = "4", letterMult = 4, frameName = "X4"}
M.X5 = {num = "5", letterMult = 5, frameName = "X5"}

local borderRgb = {0, 0, 0, 1}
local backgroundRgb = {0, 0, 0, 0.01}

local darkBorderRgb = {0, 0, 0, 1}
local darkBackgroundRgb = {0, 0, 0, 0.5}

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
	local bg = M.createSquareBackground(0, 0, width)
	group:insert(bg)
	if sqType.frameName then
        local sheet = SHEETS[boardSize]
        local module = SHEET_MODULES[boardSize]
        local frameIndex = module:getFrameIndex(sqType.frameName)
		local img = display.newImageRect(sheet, frameIndex, width, width)
		group:insert(img)
	end

	group.squareBg = bg

	return group
end

M.drawShadedSquare = function(sqType, x, y, width, boardSize)
    local group = display.newGroup()
    group.x = x
    group.y = y
    local bg = M.createSquareBackground(0, 0, width, true)
    group:insert(bg)
    if sqType.frameName then
        local sheet = SHEETS[boardSize]
        local module = SHEET_MODULES[boardSize]
        local frameIndex = module:getFrameIndex(sqType.frameName)
        local img = display.newImageRect(sheet, frameIndex, width, width)
        group:insert(img)
    end

    group.squareBg = bg
    return group
end


function M.createSquareBackground(x, y, width, isShaded)
    local radius = M.computeRadius(width)
	local myRoundedRect = display.newRoundedRect( x, y, width, width, radius )
	myRoundedRect.strokeWidth = M.computeStrokeWidth(width)
    if isShaded then
        myRoundedRect:setFillColor( darkBackgroundRgb[1], darkBackgroundRgb[2], darkBackgroundRgb[3], darkBackgroundRgb[4] )
        myRoundedRect:setStrokeColor( darkBorderRgb[1], darkBorderRgb[2], darkBorderRgb[3], darkBorderRgb[4] )
    else
	    myRoundedRect:setFillColor( backgroundRgb[1], backgroundRgb[2], backgroundRgb[3], backgroundRgb[4] )
	    myRoundedRect:setStrokeColor( borderRgb[1], borderRgb[2], borderRgb[3],borderRgb[4] )
    end
	return myRoundedRect
end

function M.computeRadius(width)
    if width > 200 then
        return 12
    elseif width > 100 then
        return 6
    else
        return 3
    end
end

function M.computeStrokeWidth(width)
    if width > 200 then
        return 6
    elseif width > 100 then
        return 4
    else
        return 3
    end
end

return M