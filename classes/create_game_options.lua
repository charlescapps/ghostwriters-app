local display = require("display")
local native = require("native")
local widget = require("widget")
local game_ui = require("common.game_ui")
local new_game_data = require("globals.new_game_data")
local checkboxes_sheet = require("spritesheets.checkboxes_sheet")
local radio_button_sheet = require("spritesheets.radio_button_sheet")

local M = {}

local Y_SPACING = 80

local mt = { __index = M }

function M.new()
    local createGameOptions = {

    }

    return setmetatable(createGameOptions, mt)
end

function M:render()
    local group = display.newGroup()

    local dictionaryOptions = self:drawDictionaryOptions()

    group:insert(dictionaryOptions)
    M.view = group

    return group
end

function M:drawDictionaryOptions()
    local group = display.newGroup()
    group.y = 150

    local title = display.newText {
        text = "Choose a Dictionary",
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
        x = 30,
        y = yPosition,
        font = native.systemFont,
        fontSize = 36
    }
    labelText.anchorX = 0
    labelText:setFillColor(0, 0, 0)

    local costText = numBooks == 0 and "" or
                tostring(numBooks) .. " books"
    local costText = display.newText {
        parent = parent,
        text = costText,
        x = display.contentCenterX,
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
        x = display.contentCenterX + 225,
        y = yPosition
    }
    radioButton.anchorX = 0
    parent:insert(radioButton)
end


return M

