local M = {}

local widget = require("widget")

M.create_background = function()
    local background = display.newImageRect( "images/book_texture.png", 750, 1334 )
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2
    return background
end


M.create_title = function(myTitleText, y, rgb)
	if not y then
		y = 150  -- default y position for titles.
	end
	if not rgb then
		rgb = {0, 0, 0}
	end
    local title = display.newText( { 
        text = myTitleText, 
        x = display.contentWidth / 2, 
        y = y, 
        font = native.systemBoldFont, 
        fontSize = 48
        } )
    title:setFillColor(rgb[1], rgb[2], rgb[3])
    return title
end 


M.create_button = function(text, id, y, onPress)
	button = widget.newButton( {
		id = id,
		x = display.contentWidth / 2,
		y = y,
		emboss = true,
		label = text,
		fontSize = 44,
		labelColor = { default = {1, 0.9, 0.9}, over = { 0, 0, 0 } },
		width = 500,
		height = 125,
		shape = "roundedRect",
		cornerRadius = 15,
		fillColor = { default={ 0.93, 0.48, 0.01, 0.7 }, over={ 0.76, 0, 0.13, 1 } },
		strokeColor = { 1, 0.2, 0.2 },
		strokeRadius = 10,
		onPress = onPress
		} )
	return button
end

return M