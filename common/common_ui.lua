local M = {}

local widget = require("widget")
local composer = require("composer")
local transition = require("transition")
local display = require("display")
local native = require("native")
local fonts = require("globals.fonts")

local DEFAULT_BACKGROUND = "images/book_texture.jpg"

local DEFAULT_BACK_BUTTON = "images/back_button_default.png"
local PRESSED_BACK_BUTTON = "images/back_button_over.png"
local DEFAULT_BACK_BUTTON2 = "images/back_button2_default.png"
local PRESSED_BACK_BUTTON2 = "images/back_button2_over.png"
local BACK_BTN_WIDTH = 100
local BACK_BTN_HEIGHT = 100

local MODAL_IMAGE = "images/book_modal.png"
local BOOK_BUTTON_DEFAULT_IMAGE = "images/book_button_default.png"
local BOOK_BUTTON_OVER_IMAGE = "images/book_button_over.png"
local BOOK_BUTTON_WIDTH = 500
local BOOK_BUTTON_HEIGHT = 300

-- Colors
-- Default button colors
M.BUTTON_FILL_COLOR_DEFAULT = { 0.93, 0.48, 0.01, 0.9 }
M.BUTTON_FILL_COLOR_OVER = { 0.72, 0.36, 0, 0.9 }

M.BUTTON_STROKE_COLOR_DEFAULT = { 0.3, 0.3, 0.3, 0.9 }
M.BUTTON_STROKE_COLOR_OVER = { 0.1, 0.1, 0.1, 1 }

M.BUTTON_LABEL_COLOR_DEFAULT = { 0.05, 0.05, 0.05, 1 }
M.BUTTON_LABEL_COLOR_OVER = { 0, 0, 0, 1 }

-- Red reject color
M.RED_FILL_COLOR_DEFAULT = { 0.99, 0.2, 0, 1 }
M.RED_FILL_COLOR_OVER = { 0.6, 0.12, 0, 0.5 }

M.RED_STROKE_COLOR_DEFAULT = { 0.42, 0.1, 0, 1 }
M.RED_STROKE_COLOR_OVER = { 0.1, 0.1, 0.1, 1 }

-- Green accept color
M.GREEN_FILL_COLOR_DEFAULT = { 0, 0.6, 0.2, 1 }
M.GREEN_FILL_COLOR_OVER = { 0, 0.3, 0.1, 0.5 }

M.GREEN_STROKE_COLOR_DEFAULT = { 0.1, 0.37, 0.19, 1 }
M.GREEN_STROKE_COLOR_OVER = { 0.1, 0.1, 0.1, 1 }

M.createBackground = function(imageFile)
	local file = imageFile or DEFAULT_BACKGROUND
    local background = display.newImageRect( file, 750, 1334 )
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2
    return background
end

M.createButton = function(text, y, onRelease, width, height, fontSize)
	local button = widget.newButton( {
		x = display.contentWidth / 2,
		y = y,
		emboss = true,
		label = text,
        font = fonts.DEFAULT_FONT,
		fontSize = fontSize or 46,
		labelColor = { default = M.BUTTON_LABEL_COLOR_DEFAULT, over = M.BUTTON_LABEL_COLOR_OVER },
		width = width or 450,
		height = height or 125,
		shape = "roundedRect",
		cornerRadius = 15,
		fillColor = { default = M.BUTTON_FILL_COLOR_DEFAULT, over = M.BUTTON_FILL_COLOR_OVER },
		strokeColor = { default = M.BUTTON_STROKE_COLOR_DEFAULT, over = M.BUTTON_STROKE_COLOR_OVER },
		strokeWidth = 2,
		onRelease = onRelease
		} )
	return button
end

M.createImageButton = function(y, width, height, defaultFile, overFile, onRelease)

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


M.createImageButtonWithText = function(defaultFile, overFile, imgY, title, subtitle, onRelease, size)
    local group = display.newGroup()
    size = size or 300
    local imgButton = M.createImageButton(imgY, size, size, defaultFile, overFile, onRelease)
    imgButton.x = display.contentWidth / 2
    imgButton.y = imgY
    
    local titleText = display.newText {
    	parent = group, 
    	text = title, 
    	x = display.contentWidth / 2, 
    	y = imgY + size / 2 + 25,
    	width = display.contentWidth, 
    	height = 50, 
    	font = fonts.BOLD_FONT,
    	fontSize = 40,
    	align = "center"
    	} 

    titleText:setFillColor(0, 0, 0)

    local subtitleText = display.newText {
    	parent = group, 
    	text = subtitle, 
    	x = display.contentWidth / 2, 
    	y = imgY + size / 2 + 65,
    	width = display.contentWidth, 
    	height = 40, 
    	font = fonts.DEFAULT_FONT,
    	fontSize = 36,
    	align = "center" }
    subtitleText:setFillColor(0, 0, 0)

    group:insert(imgButton)

    return group
end

M.createBackButton = function(x, y, sceneName, beforeTransition, afterTransition, alternate)
-- Helper to call "beforeTransition", then go to the previous or specified scene, then call "afterTransition"
    local onRelease = function(event)
        if beforeTransition then
            beforeTransition()
        end

        if not sceneName then
            sceneName = composer.getSceneName("previous")
        end

        composer.gotoScene(sceneName, "fade")

        if afterTransition then
            afterTransition()
        end
    end
    return widget.newButton {
        x = x,
        y = y,
        width = BACK_BTN_WIDTH,
        height = BACK_BTN_HEIGHT,
        defaultFile = alternate and DEFAULT_BACK_BUTTON2 or DEFAULT_BACK_BUTTON,
        overFile = alternate and PRESSED_BACK_BUTTON2 or PRESSED_BACK_BUTTON,
        onRelease = onRelease
    }
end

M.createInfoModal = function(titleText, text, onClose, titleFontSize, fontSize, fontColor, imgFile, imgWidth, imgHeight, textCenterX, textCenterY, align, textWidth)
    local group = display.newGroup()
    group.x, group.y = display.contentCenterX, display.contentCenterY
    group.alpha = 0

    fontColor = fontColor or {0, 0, 0}

    local background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    background:setFillColor(0, 0, 0, 0.5)

    local modalImage = display.newImageRect(group, imgFile or MODAL_IMAGE, imgWidth or 650, imgHeight or 484)

    local modalTitle = display.newText {
        parent = group,
        x = textCenterX or 0,
        y = textCenterY or -100,
        text = titleText,
        width = textWidth or 600,
        height = 125,
        font = fonts.BOLD_FONT,
        fontSize = titleFontSize or 60,
        align = "center"
    }
    modalTitle:setFillColor(fontColor[1], fontColor[2], fontColor[3])

    local modalText = display.newText {
        parent = group,
        x = textCenterX or 0,
        y = (textCenterY and (textCenterY + 25)) or -75,
        text = text,
        width = textWidth or 600,
        height = 900,
        font = fonts.DEFAULT_FONT,
        fontSize = fontSize or 40,
        align = align or "center"
    }
    modalText.anchorY = 0
    modalText:setFillColor(fontColor[1], fontColor[2], fontColor[3])

    local onComplete = function()
        if onClose then
            onClose()
        end
        group:removeSelf()
    end

    local onCancel = function()
        group:removeSelf()
    end

    group:insert(background)
    group:insert(modalImage)
    group:insert(modalTitle)
    group:insert(modalText)

    background:addEventListener("touch", function(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            transition.fadeOut(group, {
                onComplete = onComplete,
                onCancel = onCancel
            })
        end
        return true
    end)

    transition.fadeIn(group, { time = 1000 })

    return group
end

function M.createLink(linkText, x, y, fontSize, onPress)
    local LINK_COLOR = {0, 0.43, 1 }
    local LINK_OVER_COLOR = { 0, 0.2, 0.6 }
    local link = display.newText {
        text = linkText,
        font = fonts.DEFAULT_FONT,
        fontSize = fontSize or 36,
        x = x or display.contentWidth / 2,
        y = y or display.contentHeight / 2,
        align = "center"
    }
    link:setFillColor(LINK_COLOR[1], LINK_COLOR[2], LINK_COLOR[3])
    link:addEventListener("touch", function(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(link)
            link:setFillColor(LINK_OVER_COLOR[1], LINK_OVER_COLOR[2], LINK_OVER_COLOR[3])
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            link:setFillColor(LINK_COLOR[1], LINK_COLOR[2], LINK_COLOR[3])
            if onPress then
                onPress()
            end
        elseif event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            link:setFillColor(LINK_COLOR[1], LINK_COLOR[2], LINK_COLOR[3])
        end
    end)

    return link
end

function M.truncateName(username, maxLen)
    if not username then
        return username
    end
    if username:len() <= maxLen then
        return username
    end
    return username:sub(1, maxLen) .. ".."
end

return M