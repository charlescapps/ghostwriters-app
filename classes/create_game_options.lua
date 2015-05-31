local display = require("display")
local native = require("native")
local widget = require("widget")
local game_ui = require("common.game_ui")
local new_game_data = require("globals.new_game_data")
local stepper_sheet = require("spritesheets.stepper_sheet")
local radio_button_sheet = require("spritesheets.radio_button_sheet")
local common_api = require("common.common_api")
local fonts = require("globals.fonts")

local M = {}

local Y_SPACING = 80
local LEFT_COLUMN = 30
local MID_COLUMN = display.contentCenterX
local RIGHT_COLUMN = display.contentCenterX + 240

local mt = { __index = M }

function M.new(onUpdateCost)
    local createGameOptions = {
        onUpdateCost = onUpdateCost
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
    group.y = 255

    local title = display.newText {
        text = "Choose Dictionary",
        font = fonts.BOLD_FONT,
        fontSize = 44,
        x = display.contentCenterX
    }
    title:setFillColor(0, 0, 0)

    self.plainEnglishOption = self:drawDictionaryOption(group, 100, "English", nil, 0, true)
    self.poeOption = self:drawDictionaryOption(group, 200, "Edgar Allen Poe", common_api.DICT_POE, 1, false)
    self.lovecraftOption = self:drawDictionaryOption(group, 300, "H.P. Lovecraft", common_api.DICT_LOVECRAFT, 1, false)
    self.mythosOption = self:drawDictionaryOption(group, 400, "Cthulhu Mythos", common_api.DICT_MYTHOS, 2, false)

    group:insert(title)

    return group
end

function M:getDictionaryCost()
    if self.plainEnglishOption.isOn then
        return 0
    elseif self.poeOption.isOn then
        return 1
    elseif self.lovecraftOption.isOn then
        return 1
    elseif self.mythosOption.isOn then
        return 2
    end
    print("Error - none of the Dictionary options had isOn == true.")
    return 0
end

function M:drawDictionaryOption(parent, yPosition, text, specialDict, numBooks, isSelected)
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
        font = fonts.BOLD_FONT,
        fontSize = 36
    }
    costText.anchorX = 0
    costText:setFillColor(0, 0, 0)

    local function onRelease(event)
        if event.target.isOn then
            print("Radio button for dict " .. tostring(specialDict) .. " selected!")
            new_game_data.specialDict = specialDict
            self.onUpdateCost()
        end
    end

    local radioButton = widget.newSwitch {
        initialSwitchState = isSelected,
        style = "radio",
        sheet = game_ui:getRadioButtonSheet(),
        width = 60,
        height = 60,
        frameOn = radio_button_sheet:getFrameIndex("radio_button_on"),
        frameOff = radio_button_sheet:getFrameIndex("radio_button_off"),
        x = RIGHT_COLUMN,
        y = yPosition,
        onRelease = onRelease
    }
    parent:insert(radioButton)
    return radioButton
end

function M.drawBonusOptions()
    local group = display.newGroup()
    group.y = 750

    local title = display.newText {
        text = "Choose Bonuses",
        font = fonts.BOLD_FONT,
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
        font = fonts.BOLD_FONT,
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

