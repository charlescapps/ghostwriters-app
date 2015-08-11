local M = {}

local back_button_setup = require("android.back_button_setup")
local widget = require("widget")
local composer = require("composer")
local transition = require("transition")
local display = require("display")
local fonts = require("globals.fonts")
local timer = require("timer")
local native = require("native")

local DEFAULT_BACKGROUND = "images/book_texture.jpg"

local BACK_BTN_WIDTH = 130
local BACK_BTN_HEIGHT = 130

local MODAL_IMAGE = "images/book_modal.png"

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

    local function onTouch(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            native.setKeyboardFocus(nil)
        elseif event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
        end

        return true
    end

    background:addEventListener("touch", onTouch)

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

M.createBackButton = function(x, y, sceneName, beforeTransition, afterTransition, alternate, width, height)
-- Helper to call "beforeTransition", then go to the previous or specified scene, then call "afterTransition"
    local startScene = composer.getSceneName("current")
    local onRelease = function(event)

        local currentSceneName = composer.getSceneName("current")

        if currentSceneName ~= startScene then
            print("ERROR - current scene is " .. currentSceneName .. ", but start scene = " .. startScene)
            return true
        end

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

        return true
    end

    alternate = alternate or ""
    local defaultFile = "images/back_button" .. alternate .. "_default.png"
    local overFile = "images/back_button" .. alternate .. "_over.png"

    local backButton = widget.newButton {
        x = x,
        y = y,
        width = width or BACK_BTN_WIDTH,
        height = height or BACK_BTN_HEIGHT,
        defaultFile = defaultFile,
        overFile = overFile,
        onRelease = onRelease
    }

    backButton.onReleaseListener = onRelease

    backButton:addEventListener("finalize", function(event)
        back_button_setup.setupDefaultBackListener()
    end)

    return backButton
end

M.createInfoModal = function(titleText, text, onClose, titleFontSize, fontSize, fontColor, imgFile, imgWidth, imgHeight, textCenterX, textCenterY, align, textWidth, timeout)
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
        if onClose and not group.ranOnClose then
            group.ranOnClose = true
            onClose()
        end
        M.safeRemove(group)
    end

    local onCancel = function()
        M.safeRemove(group)
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

    -- Fade out after 1.25 seconds of displaying the info modal
    if type(timeout) ~= "number" then
        timeout = 1250
    end

    local function onFadeIn()
        if timeout > 0 then
            timer.performWithDelay(timeout, function()
                if not group or not group.removeSelf or group.ranOnClose then
                    return
                end

                transition.cancel(group)
                transition.fadeOut(group, {
                    onComplete = onComplete,
                    onCancel = onCancel
                })
            end)
        end
    end

    transition.fadeIn(group, { time = 500, onComplete = onFadeIn })

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
        return true
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

function M.drawScreen()
    local screen = display.newRect(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
    screen:setFillColor(0, 0, 0, 0.5)

    screen:addEventListener("touch", function(event)
        return true
    end)

    screen:addEventListener("tap", function(event)
        return true
    end)

    return screen
end

function M.safeRemove(displayObj)
    if displayObj and displayObj.removeSelf then
        displayObj:removeSelf()
    end
end

function M.fadeOutThenRemove(displayObj, opts, afterRemoval)
    if not displayObj then
        print("ERROR - nil displayObj provided in fadeOutThenRemove!")
        return
    end
    if not displayObj.removeSelf then
        print("ERROR - displayObj has no 'removeSelf' method in fadeOutThenRemove")
        return
    end

    local function onComplete()
        if displayObj and displayObj.removeSelf then
            displayObj:removeSelf()
            if afterRemoval then
                afterRemoval(displayObj)
            end
        end
    end

    opts = opts or {}
    opts.time = opts.time or 1000
    opts.onComplete = onComplete
    opts.onCancel = onComplete

    transition.fadeOut(displayObj, opts)
end

function M.getContentCoords(displayObj)
    if displayObj.parent and displayObj.parent.localToContent then
        return displayObj.parent:localToContent(displayObj.x, displayObj.y)
    else
        return displayObj.x, displayObj.y
    end
end

function M.isValidDisplayObj(obj)
    return obj and obj.removeSelf and true
end

function M.disableButton(button)
    if M.isValidDisplayObj(button) then
       button:setEnabled(false)
       button:setFillColor(0.5, 0.5, 0.5)
    end
end

function M.enableButton(button, color)
    if M.isValidDisplayObj(button) then
        button:setEnabled(true)
        color = color or { 1, 1, 1 }
        button:setFillColor(color[1], color[2], color[3])
    end
end

function M.getScaleFromParent(obj)

    while obj do
        if type(obj.xScale) == "number" and obj.xScale ~= 1 then
            return obj.xScale
        end

        obj = obj.parent
    end

    return nil
end

return M