local M = {}

local widget = require("widget")
local composer = require("composer")
local transition = require("transition")
local display = require("display")

local DEFAULT_BACKGROUND = "images/book_texture.png"

local DEFAULT_BACK_BUTTON = "images/back-button.png"
local PRESSED_BACK_BUTTON = "images/back-button-pressed.png"
local BACK_BTN_WIDTH = 75
local BACK_BTN_HEIGHT = 75

local MODAL_IMAGE = "images/book_modal.png"

M.create_background = function(imageFile)
	local file = imageFile or DEFAULT_BACKGROUND
    local background = display.newImageRect( file, 750, 1334 )
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2
    return background
end

M.create_image = function(imageFile, width, height, x, y)
    local img = display.newImageRect( imageFile, width, height )
    img.x = x
    img.y = y
    return img
end

M.create_title = function(myTitleText, y, rgb, fontSize)
	local useFontSize = fontSize or 48
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
        fontSize = useFontSize
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

M.create_img_button = function(y, width, height, defaultFile, overFile, onRelease)

	return widget.newButton({
		x = display.contentWidth / 2,
		y = y,
		width = width,
		height = height,
		defaultFile = defaultFile, 
		overFile = overFile,
		onRelease = onRelease
	})
end

M.create_img_button2 = function(x, y, width, height, defaultFile, overFile, onPress, onRelease)

    return widget.newButton {
        x = x,
        y = y,
        width = width,
        height = height,
        defaultFile = defaultFile,
        overFile = overFile,
        onPress = onPress,
        onRelease = onRelease
    }
end

M.create_back_button = function(x, y, sceneName, beforeTransition, afterTransition)
    -- Helper to call "beforeTransition", then go to the previous or specified scene, then call "afterTransition"
    local onRelease = function(event)
        if beforeTransition then
            beforeTransition()
        end

        if not sceneName then
            sceneName = composer.getSceneName("previous")
        end

        composer.gotoScene(sceneName)

        if afterTransition then
            afterTransition()
        end
    end
    return widget.newButton {
        x = x,
        y = y,
        width = BACK_BTN_WIDTH,
        height = BACK_BTN_HEIGHT,
        defaultFile = DEFAULT_BACK_BUTTON,
        overFile = PRESSED_BACK_BUTTON,
        onRelease = onRelease
    }
end

M.find_by_id = function(group, id)
	for i=1, #array do
		if group[i] and group[i].id == id then
			return group[i]
		end
	end
	return nil
end

M.create_img_button_group = function(defaultFile, overFile, imgY, title, subtitle, onRelease)
    local group = display.newGroup()
    local imgButton = M.create_img_button(imgY, 300, 300, defaultFile, overFile, onRelease)
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

M.create_info_modal = function(titleText, text, onClose, x, y, fontSize)
    if not x then
        x = display.contentWidth / 2
    end
    if not y then
        y = display.contentHeight / 2
    end
    if not fontSize then
        fontSize = 50
    end

    local group = display.newGroup()
    group.x, group.y = x, y

    local modalImage = display.newImageRect(group, MODAL_IMAGE, 650, 484)

    local modalTitle = display.newText {
        parent = group,
        x = 0,
        y = -100,
        text = titleText,
        width = 600,
        height = 125,
        font = native.systemBoldFont,
        fontSize = 60,
        align = "center"
    }
    modalTitle:setFillColor(0, 0, 0)

    local modalText = display.newText {
        parent = group,
        x = 0,
        y = 75,
        text = text,
        width = 600,
        height = 250,
        font = native.systemBoldFont,
        fontSize = 40,
        align = "center"
    }
    modalText:setFillColor(0, 0, 0)

    local onComplete = function()
        group:removeSelf()
        if onClose then
            onClose()
        end
    end

    group:insert(modalImage)
    group:insert(modalTitle)
    group:insert(modalText)

    group:addEventListener("touch", function(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            transition.fadeOut(group, {
                onComplete = function()
                    group:removeSelf()
                    if onClose then
                        onClose()
                    end
                end
            })
        end
        return true
    end)

    return group
end

return M