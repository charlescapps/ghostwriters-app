local display = require("display")
local fonts = require("globals.fonts")
local widget = require("widget")

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
        selectedIndex = 1,
        rows = opts.rows,
        left = opts.left or 0,
        top = opts.top or 0,
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
        fontSize = opts.fontSize or 40
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

    local text1 = display.newText {
        text = row.text1,
        fontSize = self.fontSize,
        font = self.column1Font,
        x = self.column1Left
    }
    text1.anchorX = 0

    local text2 = display.newText {
        text = row.text2,
        fontSize = self.fontSize,
        font = self.column2Font,
        x = self.column2Left
    }
    text2.anchorX = 0

    local function onRelease()
        --
    end

    local pickerButton = widget.newButton {
        x = self.column3Center,
        width = self.rowHeight,
        height = self.rowHeight,
        defaultImage = "images/picker_default.png",
        overImage = "images/picker_over.png",
        onRelease = onRelease
    }

    group:insert(text1)
    group:insert(text2)
    group:insert(pickerButton)

    return group
end



return M

