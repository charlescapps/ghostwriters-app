local new_game_data = require("globals.new_game_data")
local imgs = require("globals.imgs")
local display = require("display")
local transition = require("transition")
local native = require("native")
local widget = require("widget")
local graphics = require("graphics")
local radio_button_sheet = require("spritesheets.radio_button_sheet")
local common_api = require("common.common_api")

local game_options_modal = {}
local game_options_modal_mt = { __index = game_options_modal }

function game_options_modal.new(parentScene)
    if not game_options_modal.radioButtonSheet then
        game_options_modal.radioButtonSheet = graphics.newImageSheet("spritesheets/radio_button_sheet.png", radio_button_sheet:getSheet())
    end

    local gameOptionsModal = {
        parentScene = parentScene
    }
    return setmetatable(gameOptionsModal, game_options_modal_mt)
end

function game_options_modal:render()
    self.view = display.newGroup()
    self.view.alpha = 0

    self.bg = self:drawBlackBackground()
    self.oldBook = self:drawOldBook()
    self.options = self:drawOptions()

    self.view:insert(self.bg)
    self.view:insert(self.oldBook)
    self.view:insert(self.options)
    return self.view
end

function game_options_modal:show()
    transition.fadeIn(self.view, {
        time = 800
    })
end

function game_options_modal:hide()
    transition.fadeOut(self.view, {
        time = 800
    })
end

function game_options_modal:drawBlackBackground()
    local bg = display.newRect(self.parentScene.view, display.contentWidth / 2, display.contentHeight / 2,
        display.contentWidth, display.contentHeight)
    bg:setFillColor(0, 0, 0, 0.5)
    local that = self
    function bg:touch(event)
        if event.phase == "began" then
           display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            that:hide()
        elseif event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end
    bg:addEventListener("touch")
    return bg
end

function game_options_modal:drawOldBook()
    local book = display.newImageRect(imgs.OLD_BOOK, imgs.OLD_BOOK_WIDTH, imgs.OLD_BOOK_HEIGHT)
    book.x = display.contentWidth / 2
    book.y = display.contentHeight / 2
    function book:touch(event)
        return true
    end
    book:addEventListener("touch")
    return book
end

function game_options_modal:drawOptions()
    local Y_SPACING = 80

    local group = display.newGroup()
    group.x, group.y = 150, 250

    -- Word density title
    local wordDensityTitle = display.newText {
        text = "Word Density",
        font = native.systemFontBold,
        fontSize = 40
    }
    wordDensityTitle.anchorX = 0
    group:insert(wordDensityTitle)

    -- Sparse density text and radio button
    local sparseText = display.newText {
        text = "Sparse (6-15 words)",
        font = native.systemFont,
        fontSize = 32,
        y = Y_SPACING
    }
    sparseText.anchorX = 0
    group:insert(sparseText)

    local function onReleaseSparse(event)
        if event and event.target and event.target.isOn then
            new_game_data.gameDensity = common_api.LOW_DENSITY
        end
    end

    local sparseRadio = widget.newSwitch {
        initialSwitchState = false,
        style = "radio",
        sheet = game_options_modal.radioButtonSheet,
        width = 60,
        height = 60,
        frameOn = radio_button_sheet:getFrameIndex("radio_button_on"),
        frameOff = radio_button_sheet:getFrameIndex("radio_button_off"),
        x = 450,
        y = Y_SPACING,
        onRelease = onReleaseSparse
    }
    group:insert(sparseRadio)

    -- Regular density text and radio button
    local regularText = display.newText {
        text = "Regular (7-18 words)",
        font = native.systemFont,
        fontSize = 32,
        y = Y_SPACING * 2
    }
    regularText.anchorX = 0
    group:insert(regularText)

    local function onReleaseRegular(event)
        if event and event.target and event.target.isOn then
            new_game_data.gameDensity = common_api.MEDIUM_DENSITY
        end
    end

    local regularRadio = widget.newSwitch {
        initialSwitchState = true,
        style = "radio",
        sheet = game_options_modal.radioButtonSheet,
        width = 60,
        height = 60,
        frameOn = radio_button_sheet:getFrameIndex("radio_button_on"),
        frameOff = radio_button_sheet:getFrameIndex("radio_button_off"),
        x = 450,
        y = Y_SPACING * 2,
        onRelease = onReleaseRegular
    }
    group:insert(regularRadio)

    -- Dense density text and radio button
    local denseText = display.newText {
        text = "Dense (8-21 words)",
        font = native.systemFont,
        fontSize = 32,
        y = Y_SPACING * 3
    }
    denseText.anchorX = 0
    group:insert(denseText)

    local function onReleaseDense(event)
        if event and event.target and event.target.isOn then
            new_game_data.gameDensity = common_api.HIGH_DENSITY
        end
    end

    local denseRadio = widget.newSwitch {
        initialSwitchState = false,
        style = "radio",
        sheet = game_options_modal.radioButtonSheet,
        width = 60,
        height = 60,
        frameOn = radio_button_sheet:getFrameIndex("radio_button_on"),
        frameOff = radio_button_sheet:getFrameIndex("radio_button_off"),
        x = 450,
        y = Y_SPACING * 3,
        onRelease = onReleaseDense
    }
    group:insert(denseRadio)

    return group

end

return game_options_modal

