local display = require("display")
local fonts = require("globals.fonts")
local widget = require("widget")
local game_ui = require("common.game_ui")
local radio_button_sheet = require("spritesheets.radio_button_sheet")
local transition = require("transition")
local new_game_data = require("globals.new_game_data")

local M = {}

local meta = {
    __index = M
}


--[[
-- Example row
{
    text1 = "English",
    text2 = "Free",
    value = "POE"
 }
 ]]

function M.new(opts)
    local rowWidth = opts.rowWidth or display.contentWidth

    local prettyPicker = {
        view = display.newGroup(),
        pickerY = opts.pickerY,
        selectedIndex = opts.selectedIndex or 1,
        rows = opts.rows,
        left = opts.left or 0,
        padding = opts.padding or 20,
        topSpace = opts.topSpace or 150,
        rowWidth = rowWidth,
        rowHeight = opts.rowHeight or 100,
        column1Left = opts.column1Left or 20,
        column2Left = opts.column2Left or rowWidth / 2,
        column3Center = opts.column3Center or rowWidth - 100,
        column1Font = opts.column1Font or fonts.DEFAULT_FONT,
        column2Font = opts.column2Font or fonts.BOLD_FONT,
        bgImage = opts.bgImage,
        bgWidth = opts.bgWidth,
        bgHeight = opts.bgHeight,
        fontSize = opts.fontSize or 40,
        onUpdate = opts.onUpdate
    }

    prettyPicker.view.left = prettyPicker.left
    prettyPicker.view.top = prettyPicker.top

    return setmetatable(prettyPicker, meta)
end

function M:render()
    self.pickerRow = self:drawPickerRow()
    self.view:insert(self.pickerRow)

    return self.view
end


function M:drawPickerRow()
    local i = self.selectedIndex
    local row = self.rows[i]

    local group = display.newGroup()
    group.y = self.pickerY

    local text1 = display.newText {
        text = row.text1,
        fontSize = self.fontSize,
        font = self.column1Font,
        x = self.column1Left
    }
    text1.anchorX = 0
    text1:setFillColor(0, 0, 0)

    local text2 = display.newText {
        text = row.text2,
        fontSize = self.fontSize,
        font = self.column2Font,
        x = self.column2Left
    }
    text2.anchorX = 0
    text2:setFillColor(0, 0, 0)

    local function onRelease()
        --Draw the options modal
        if not self.optionsModal then
            self.optionsModal = self:drawOptionsModal()
        end

        self.optionsModal:toFront()
        transition.fadeIn (self.optionsModal, {
            time = 1000
        })

    end

    local buttonSize = self.rowHeight * .75
    local pickerButton = widget.newButton {
        width = buttonSize,
        height = buttonSize,
        defaultFile = "images/picker_default.png",
        overFile = "images/picker_over.png",
        onRelease = onRelease
    }
    pickerButton.x = self.column3Center
    pickerButton.y = 0

    group:insert(text1)
    group:insert(text2)
    group:insert(pickerButton)

    return group
end

function M:drawOptionsModal()
    local group = display.newGroup()
    group.x = display.contentCenterX
    group.y = display.contentCenterY
    group.alpha = 0

    local bg = display.newImageRect(self.bgImage, self.bgWidth, self.bgHeight)
    group:insert(bg)

    for i = 1, #self.rows do
        self:drawOptionRow(i, group)
    end

    return group
end

function M:drawOptionRow(index, parent)
    local row = self.rows[index]
    local rowY = -self.bgHeight / 2 + self.padding * index + (index - 0.5) * self.rowHeight + self.topSpace

    local text1 = display.newText {
        text = row.text1,
        fontSize = self.fontSize,
        font = self.column1Font,
        x = self.column1Left - display.contentCenterX,
        y = rowY
    }
    text1.anchorX = 0
    text1:setFillColor(1, 1, 1)

    local text2 = display.newText {
        text = row.text2,
        fontSize = self.fontSize,
        font = self.column2Font,
        x = self.column2Left - display.contentCenterX,
        y = rowY
    }
    text2.anchorX = 0
    text2:setFillColor(1, 1, 1)

    local function onRelease()
        if self.optionsModal then
            transition.fadeOut(self.optionsModal, { time = 1000 })
            self.selectedIndex = index

            if self.pickerRow and self.pickerRow.removeSelf then
                self.pickerRow:removeSelf()
            end

            self.pickerRow = self:drawPickerRow()
            self.view:insert(self.pickerRow)

            if self.onUpdate then
                self.onUpdate()
            end
        end
    end

    local radioButton = widget.newSwitch {
        initialSwitchState = index == self.selectedIndex,
        style = "radio",
        sheet = game_ui:getRadioButtonSheet(),
        width = 60,
        height = 60,
        frameOn = radio_button_sheet:getFrameIndex("radio_button_on"),
        frameOff = radio_button_sheet:getFrameIndex("radio_button_off"),
        x = self.column3Center - display.contentCenterX,
        y = rowY,
        onRelease = onRelease
    }

    parent:insert(text1)
    parent:insert(text2)
    parent:insert(radioButton)

end

function M:getValue()
    local i = self.selectedIndex
    local row = self.rows[i]
    return row.value
end


return M
