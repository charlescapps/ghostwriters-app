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


M.create_button = function(text, id, y, onEvent)
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
		onEvent = onEvent
		} )
	return button
end

M.create_img_button = function(y, width, height, defaultFile, overFile, onPress, onRelease)

	return widget.newButton({
		x = display.contentWidth / 2,
		y = y,
		width = width,
		height = height,
		defaultFile = defaultFile, 
		overFile = overFile,
		onPress = onPress,
		onRelease = onRelease
	})
end

M.find_by_id = function(group, id)
	for i=1, #array do
		if group[i] and group[i].id == id then
			return group[i]
		end
	end
	return nil
end

M.create_img_button_group = function(defaultFile, overFile, imgY, title, subtitle, onPress, onRelease)
    local group = display.newGroup()
    local imgButton = M.create_img_button(imgY, 300, 300, defaultFile, overFile,  onPress, onRelease)
    imgButton.x = display.contentWidth / 2
    imgButton.y = imgY
    
    local titleText = display.newText {
    	parent = group, 
    	text = title, 
    	x = display.contentWidth / 2, 
    	y = imgY + 175, 
    	width = display.contentWidth, 
    	height = 50, 
    	font = native.systemFontBold, 
    	fontSize = 40,
    	align = "center"
    	} 

    titleText:setFillColor(0, 0, 0)

    local subtitleText = display.newText {
    	parent = group, 
    	text = subtitle, 
    	x = display.contentWidth / 2, 
    	y = imgY + 220, 
    	width = display.contentWidth, 
    	height = 40, 
    	font = native.systemFont, 
    	fontSize = 30,
    	align = "center" }
    subtitleText:setFillColor(0, 0, 0)

    group:insert(imgButton)

    return group
end

return M