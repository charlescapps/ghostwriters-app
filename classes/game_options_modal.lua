local new_game_data = require("globals.new_game_data")
local imgs = require("globals.imgs")
local display = require("display")
local transition = require("transition")
local native = require("native")
local widget = require("widget")
local game_ui = require("common.game_ui")
local checkboxes_sheet = require("spritesheets.checkboxes_sheet")
local radio_button_sheet = require("spritesheets.radio_button_sheet")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local fonts = require("globals.fonts")

local game_options_modal = {}
local game_options_modal_mt = { __index = game_options_modal }

function game_options_modal.new(parentScene, isReadOnly)

    local gameOptionsModal = {
        parentScene = parentScene,
        isReadOnly = isReadOnly
    }
    return setmetatable(gameOptionsModal, game_options_modal_mt)
end

function game_options_modal:render()
    self.view = display.newGroup()
    self.view.alpha = 0

    self.bg = self:drawBlackBackground()
    self.oldBook = self:drawOldBook()
    self.gameDensityOptions = self:drawGameDensityOptions()
    self.bonusOptions = self:drawBonusOptions()
    self.doneButton = self:drawDoneButton()

    self.view:insert(self.bg)
    self.view:insert(self.oldBook)
    self.view:insert(self.gameDensityOptions)
    self.view:insert(self.bonusOptions)
    self.view:insert(self.doneButton)
    return self.view
end

function game_options_modal:show()
    if not self.view then
        return
    end
    self.view:toFront()

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

function game_options_modal:drawGameDensityOptions()
    local Y_SPACING = 80

    local group = display.newGroup()
    local radioGroup = display.newGroup()
    group:insert(radioGroup)
    group.x, group.y = 150, 250

    -- Word density title
    local wordDensityTitle = display.newText {
        text = "Word Density",
        font = fonts.BOLD_FONT,
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
        initialSwitchState = new_game_data.gameDensity == common_api.LOW_DENSITY,
        style = "radio",
        sheet = self:getRadioButtonSheet(),
        width = 60,
        height = 60,
        frameOn = radio_button_sheet:getFrameIndex("radio_button_on"),
        frameOff = radio_button_sheet:getFrameIndex("radio_button_off"),
        x = 450,
        y = Y_SPACING,
        onRelease = onReleaseSparse
    }
    radioGroup:insert(sparseRadio)
    self:setRadioButtonEnabledState(sparseRadio, radioGroup)

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
        initialSwitchState = new_game_data.gameDensity == common_api.MEDIUM_DENSITY,
        style = "radio",
        sheet = self:getRadioButtonSheet(),
        width = 60,
        height = 60,
        frameOn = radio_button_sheet:getFrameIndex("radio_button_on"),
        frameOff = radio_button_sheet:getFrameIndex("radio_button_off"),
        x = 450,
        y = Y_SPACING * 2,
        onRelease = onReleaseRegular
    }
    radioGroup:insert(regularRadio)
    self:setRadioButtonEnabledState(regularRadio, radioGroup)

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
        initialSwitchState = new_game_data.gameDensity == common_api.HIGH_DENSITY,
        style = "radio",
        sheet = self:getRadioButtonSheet(),
        width = 60,
        height = 60,
        frameOn = radio_button_sheet:getFrameIndex("radio_button_on"),
        frameOff = radio_button_sheet:getFrameIndex("radio_button_off"),
        x = 450,
        y = Y_SPACING * 3,
        onRelease = onReleaseDense
    }
    radioGroup:insert(denseRadio)
    self:setRadioButtonEnabledState(denseRadio, radioGroup)

    return group

end

function game_options_modal:getRadioButtonSheet()
    return game_ui:getRadioButtonSheet()
end

function game_options_modal:getCheckboxesSheet()
    return game_ui:getCheckboxesSheet()
end

function game_options_modal:setRadioButtonEnabledState(radioButton, radioGroup)
    if self.isReadOnly then
        local hackScreen = common_ui.drawScreen()
        hackScreen.x, hackScreen.y = radioButton.x, radioButton.y
        hackScreen.width, hackScreen.height = radioButton.width, radioButton.height
        hackScreen:setFillColor(0.5, 0.5, 0.5, 0.01)
        radioGroup:insert(hackScreen)
    end
end

function game_options_modal:drawBonusOptions()
    local Y_SPACING = 80

    local group = display.newGroup()
    group.x, group.y = 150, 600

    -- Bonuses title
    local bonusOptionsTitle = display.newText {
        text = "Bonus Squares",
        font = fonts.BOLD_FONT,
        fontSize = 40
    }
    bonusOptionsTitle.anchorX = 0
    group:insert(bonusOptionsTitle)

    -- Random bonuses option - text and radio button
    local randomBonusesOptionText = display.newText {
        text = "Random bonuses?",
        font = native.systemFont,
        fontSize = 36,
        y = Y_SPACING
    }
    randomBonusesOptionText.anchorX = 0
    group:insert(randomBonusesOptionText)

    local function onReleaseCheckbox(event)
        if event and event.target and event.target.isOn then
            new_game_data.bonusesType = common_api.RANDOM_BONUSES
        else
            new_game_data.bonusesType = common_api.FIXED_BONUSES
        end
    end

    local randomBonusesCheckbox = widget.newSwitch {
        initialSwitchState = new_game_data.bonusesType == common_api.RANDOM_BONUSES,
        style = "checkbox",
        sheet = self:getCheckboxesSheet(),
        width = 60,
        height = 60,
        frameOn = checkboxes_sheet:getFrameIndex("checkbox_checked"),
        frameOff = checkboxes_sheet:getFrameIndex("checkbox_unchecked"),
        x = 450,
        y = Y_SPACING,
        onRelease = onReleaseCheckbox
    }
    group:insert(randomBonusesCheckbox)
    self:setRadioButtonEnabledState(randomBonusesCheckbox, group)

    return group

end

function game_options_modal:drawDoneButton()
    local function onRelease()
        self:hide()
    end
    return common_ui.createButton("Done", 900, onRelease, 400)
end

return game_options_modal

