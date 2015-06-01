local display = require("display")
local native = require("native")
local widget = require("widget")
local game_ui = require("common.game_ui")
local stepper_sheet = require("spritesheets.stepper_sheet")
local common_api = require("common.common_api")
local pretty_picker = require("classes.pretty_picker")
local fonts = require("globals.fonts")
local imgs = require("globals.imgs")
local new_game_data = require("globals.new_game_data")

local M = {}

local LEFT_COLUMN = 50
local MID_COLUMN = display.contentCenterX
local RIGHT_COLUMN = display.contentCenterX + 250

local mt = { __index = M }

function M.new(onUpdateOptions)
    local createGameOptions = {
        onUpdateOptions = onUpdateOptions
    }

    return setmetatable(createGameOptions, mt)
end

function M:render()
    local group = display.newGroup()

    local boardSizeOptions = self:drawBoardSizeOptions()
    local dictionaryOptions = self:drawDictionaryOptions()
    local bonusOptions = self:drawBonusOptions()

    group:insert(boardSizeOptions)
    group:insert(dictionaryOptions)
    group:insert(bonusOptions)

    M.view = group

    return group
end

function M:drawBoardSizeOptions()
    local group = display.newGroup()

    local title = display.newText {
        text = "Board Size",
        font = fonts.BOLD_FONT,
        fontSize = 44,
        x = display.contentCenterX,
        y = 300
    }
    title:setFillColor(0, 0, 0)

    local rows = {
        {
            text1 = "Small (5x5)",
            text2 = "1 book",
            value = common_api.SMALL_SIZE
        },
        {
            text1 = "Medium (9x9)",
            text2 = "3 books",
            value = common_api.MEDIUM_SIZE
        },
        {
            text1 = "Large (13x13)",
            text2 = "5 books",
            value = common_api.LARGE_SIZE
        }
    }
    local startIndex = 1
    if new_game_data.boardSize == common_api.SMALL_SIZE then
        startIndex = 1
    elseif new_game_data.boardSize == common_api.MEDIUM_SIZE then
        startIndex = 2
    elseif new_game_data.boardSize == common_api.LARGE_SIZE then
        startIndex = 3
    end

    self.boardSizePicker = pretty_picker.new {
        rows = rows,
        selectedIndex = startIndex,
        pickerY = 400,
        column1Left = LEFT_COLUMN,
        column2Left = MID_COLUMN,
        column3Center = RIGHT_COLUMN,
        bgImage = imgs.OLD_BOOK,
        bgWidth = imgs.OLD_BOOK_WIDTH,
        bgHeight = imgs.OLD_BOOK_HEIGHT,
        rowWidth = imgs.OLD_BOOK_WIDTH,
        rowHeight = 100,
        onUpdate = self.onUpdateOptions
    }

    group:insert(title)
    group:insert(self.boardSizePicker:render())

    return group
end

function M:drawDictionaryOptions()
    local group = display.newGroup()

    local title = display.newText {
        text = "Dictionary",
        font = fonts.BOLD_FONT,
        fontSize = 44,
        x = display.contentCenterX,
        y = 525
    }
    title:setFillColor(0, 0, 0)

    local rows = {
        {
            text1 = "English",
            text2 = "Free!",
            value = nil
        },
        {
            text1 = "Edgar Allan Poe",
            text2 = "1 book",
            value = common_api.DICT_POE
        },
        {
            text1 = "H.P. Lovecraft",
            text2 = "1 book",
            value = common_api.DICT_LOVECRAFT
        },
        {
            text1 = "Cthulhu Mythos",
            text2 = "1 book",
            value = common_api.DICT_MYTHOS
        }
    }

    self.dictionaryPicker = pretty_picker.new {
        rows = rows,
        pickerY = 625,
        column1Left = LEFT_COLUMN,
        column2Left = MID_COLUMN,
        column3Center = RIGHT_COLUMN,
        bgImage = imgs.OLD_BOOK,
        bgWidth = imgs.OLD_BOOK_WIDTH,
        bgHeight = imgs.OLD_BOOK_HEIGHT,
        rowWidth = imgs.OLD_BOOK_WIDTH,
        rowHeight = 100,
        onUpdate = self.onUpdateOptions
    }

    group:insert(title)
    group:insert(self.dictionaryPicker:render())

    return group
end

function M:getBoardSizeOption()
    return self.boardSizePicker:getValue()
end

function M:getDictionaryOption()
    return self.dictionaryPicker:getValue()
end

function M.drawBonusOptions()
    local group = display.newGroup()
    group.y = 750

    local title = display.newText {
        text = "Bonuses",
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

