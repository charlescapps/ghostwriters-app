local M = {}
local display = require("display")
local common_ui = require("common.common_ui")

M.NORMAL = { num = "0", letterMult = 1, wordMult = 1, img = nil }
M.DL = {num = "1", letterMult = 2, wordMult = 1, img = "images/double_letter_9x9.png"}
M.TL = {num = "2", letterMult = 3, wordMult = 1, img = "images/triple_letter_9x9.png"}
M.DW = {num = "3", letterMult = 1, wordMult = 2, img = "images/double_word_9x9.png"}
M.TW = {num = "4", letterMult = 1, wordMult = 3, img = "images/triple_word_9x9.png"}

local borderRgb = {151/256, 99/256, 54/256}
local backgroundRgb = {225/256, 189/256, 47/256}

local createSquareBackground

M.valueOf = function(str)
	if str == M.NORMAL.num then
		return M.NORMAL
	elseif str == M.DL.num then
		return M.DL
	elseif str == M.TL.num then
		return M.TL
	elseif str == M.DW.num then
		return M.DW
	elseif str == M.TW.num then
		return M.TW
	else
		error("Invalid character for a Square: " .. str)
	end
end

M.draw = function(sqType, x, y, width)
	local group = display.newGroup()
	group.x = x
	group.y = y
	local bg = createSquareBackground(0, 0, width)
	group:insert(bg)
	if sqType.img then
		local img = common_ui.create_image(sqType.img, width, width, 0, 0)
		group:insert(img)
	end

	group.squareBg = bg

	return group
end


createSquareBackground = function(x, y, width)
	local myRoundedRect = display.newRoundedRect( x, y, width, width, 12 )
	myRoundedRect.strokeWidth = 5
	myRoundedRect:setFillColor( backgroundRgb[0], backgroundRgb[1], backgroundRgb[2] )
	myRoundedRect:setStrokeColor( borderRgb[0], borderRgb[1], borderRgb[2] )
	return myRoundedRect
end

return M