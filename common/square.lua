local M = {}
local display = require("display")
local common_api = require("common.common_api")

M.NORMAL = { num = "1", letterMult = 1, images = nil }
M.DL = {num = "2", letterMult = 2, images =
{ [common_api.SMALL_SIZE] = "images/x2_tall.png", [common_api.MEDIUM_SIZE] = "images/x2_grande.png", [common_api.LARGE_SIZE] = "images/x2_venti.png" }}
M.TL = {num = "3", letterMult = 3, images =
{ [common_api.SMALL_SIZE] = "images/x3_tall.png", [common_api.MEDIUM_SIZE] = "images/x3_grande.png", [common_api.LARGE_SIZE] = "images/x3_venti.png" }}
M.QL = {num = "4", letterMult = 1, images =
{ [common_api.SMALL_SIZE] = "images/x4_tall.png", [common_api.MEDIUM_SIZE] = "images/x4_grande.png", [common_api.LARGE_SIZE] = "images/x4_venti.png" }}

M.MINE = {num = "0", letterMult = 0, images =
{ [common_api.SMALL_SIZE] = "images/mine_tall.png", [common_api.MEDIUM_SIZE] = "images/mine_grande.png", [common_api.LARGE_SIZE] = "images/mine_venti.png" }}

local borderRgb = {0, 99/256, 54/256}
local backgroundRgb = {0, 189/256, 47/256}

local darkBorderRgb = {0, 29/256, 4/256}
local darkBackgroundRgb = {0, 99/256, 1/256}

local createSquareBackground

M.valueOf = function(str)
	if str == M.NORMAL.num then
		return M.NORMAL
	elseif str == M.DL.num then
		return M.DL
	elseif str == M.TL.num then
		return M.TL
	elseif str == M.QL.num then
		return M.QL
	elseif str == M.MINE.num then
		return M.MINE
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
	if sqType.images then
		local img = display.newImageRect(sqType.images[boardSize], width, width)
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
    if sqType.images then
        local img = display.newImageRect(sqType.images[boardSize], width, width)
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