local display = require("display")
local native = require("native")
local widget = require("widget")
local game_ui = require("common.game_ui")
local new_game_data = require("globals.new_game_data")
local stepper_sheet = require("spritesheets.stepper_sheet")
local radio_button_sheet = require("spritesheets.radio_button_sheet")

local M = {}

local Y_SPACING = 80
local LEFT_COLUMN = 30
local MID_COLUMN = display.contentCenterX
local RIGHT_COLUMN = display.contentCenterX + 225

local mt = { __index = M }

function M.new()
    local createGameOptions = {

    }

    return setmetatable(createGameOptions, mt)
end

function M:render()
    local group = display.newGroup()

    local dictionaryOptions = self:drawDictionaryOptions()
    local bonusOptions = self:drawBonusOptions()

    group:insert(dictionaryOptions)
    group:insert(bonusOptions)

    M.view = group

    return group
end

function M:drawDictionaryOptions()
    local group = display.newGroup()
    group.y = 150

    local title = display.newText {
        text = "Choose Dictionary",
        font = native.systemFontBold,
        fontSize = 44,
        x = display.contentCenterX
    }
    title:setFillColor(0, 0, 0)

    self.plainEnglishOption = self:drawDictionaryOption(group, 100, " English", 0, true)
    self.victorianOption = self:drawDictionaryOption(group, 200, "+Victorian Era", 1, false)
    self.steampunkOption = self:drawDictionaryOption(group, 300, "+Steampunk", 2, false)
    self.lovecraftOption = self:drawDictionaryOption(group, 400, "+H.P. Lovecraft", 3, false)

    group:insert(title)

    return group
end

function M:drawDictionaryOption(parent, yPosition, text, numBooks, isSelected)
    local labelText = display.newText {
        parent = parent,
        text = text,
        x = LEFT_COLUMN,
        y = yPosition,
        font = native.systemFont,
        fontSize = 36
    }
    labelText.anchorX = 0
    labelText:setFillColor(0, 0, 0)

    local costText = numBooks == 0 and "Free!" or
                tostring(numBooks) .. " books"
    local costText = display.newText {
        parent = parent,
        text = costText,
        x = MID_COLUMN,
        y = yPosition,
        font = native.systemFontBold,
        fontSize = 36
    }
    costText.anchorX = 0
    costText:setFillColor(0, 0, 0)

    local radioButton = widget.newSwitch {
        initialSwitchState = isSelected,
        style = "radio",
        sheet = game_ui:getRadioButtonSheet(),
        width = 60,
        height = 60,
        frameOn = radio_button_sheet:getFrameIndex("radio_button_on"),
        frameOff = radio_button_sheet:getFrameIndex("radio_button_off"),
        x = RIGHT_COLUMN,
        y = yPosition
    }
    parent:insert(radioButton)
end

function M.drawBonusOptions()
    local group = display.newGroup()
    group.y = 700

    local title = display.newText {
        text = "Choose Bonuses",
        font = native.systemFontBold,
        fontSize = 44,
        x = display.contentCenterX
    }
    title:setFillColor(0, 0, 0)

    M.drawBonusOptionRow(group, "Blank Tiles", 100, 4)
    M.drawBonusOptionRow(group, "Double Words", 200, 2)

    group:insert(title)
    return group
end

function M.drawBonusOptionRow(parent, labelText, yPosition, maxValue)
    local label = display.newText {
        parent = parent,
        x = LEFT_COLUMN,
        y = yPosition,
        text = labelText,
        font = native.systemFont,
        fontSize = 36
    }
    label.anchorX = 0
    label:setFillColor(0, 0, 0)

    local stepperValue = display.newText {
        parent = parent,
        text = 0,
        x = MID_COLUMN,
        y = yPosition,
        font = native.systemFontBold,
        fontSize = 40
    }
    stepperValue.anchorX = 0
    stepperValue:setFillColor(0, 0, 0)

    local onPress = function(event)
        if event.phase == "increment" or event.phase == "decrement" then
           local val = event.value
           stepperValue.text = tostring(val)
        end
    end

    local stepper = widget.newStepper{
        x = RIGHT_COLUMN,
        y = yPosition,
        width = 130,
        height = 65,
        maximumValue = maxValue,
        onPress = onPress,
        sheet = game_ui:getStepperSheet(),
        defaultFrame = stepper_sheet:getFrameIndex("stepper_default"),
        noMinusFrame = stepper_sheet:getFrameIndex("stepper_no_minus"),
        noPlusFrame = stepper_sheet:getFrameIndex("stepper_no_plus"),
        minusActiveFrame = stepper_sheet:getFrameIndex("stepper_minus_active"),
        plusActiveFrame = stepper_sheet:getFrameIndex("stepper_plus_active")
    }
    parent:insert(stepper)

end


return M

