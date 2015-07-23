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
local sheet_helpers = require("globals.sheet_helpers")
local tips_helpers = require("tips.tips_helpers")

local M = {}

local LEFT_COLUMN = 20
local MID_COLUMN = display.contentCenterX
local RIGHT_COLUMN = display.contentCenterX + 275

local mt = { __index = M }

function M.new(onUpdateOptions, isReadOnly)
    local createGameOptions = {
        onUpdateOptions = onUpdateOptions,
        isReadOnly = isReadOnly
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
        fontSize = 50,
        x = display.contentCenterX,
        y = 250
    }
    title:setFillColor(0, 0, 0)

    local titleTipButton = tips_helpers.drawTipButton(
        "Choose the board size.\n\n" ..
        "The larger the board, the more your rating increases for winning games.", 100, 100)
    titleTipButton.anchorX = 0
    titleTipButton.x = title.x + title.contentWidth / 2
    titleTipButton.y = title.y

    local rows = {
        {
            text1 = "Small (5x5)",
            text2 = "1 x",
            value = common_api.SMALL_SIZE
        },
        {
            text1 = "Medium (9x9)",
            text2 = "3 x",
            value = common_api.MEDIUM_SIZE
        },
        {
            text1 = "Large (13x13)",
            text2 = "5 x",
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
        pickerY = 350,
        column1Left = LEFT_COLUMN,
        column2Left = MID_COLUMN,
        column2ImageFile = "images/currency_book.png",
        column3Center = RIGHT_COLUMN,
        bgImage = imgs.OLD_BOOK,
        bgWidth = imgs.OLD_BOOK_WIDTH,
        bgHeight = imgs.OLD_BOOK_HEIGHT,
        rowWidth = imgs.OLD_BOOK_WIDTH,
        rowHeight = 100,
        onUpdate = self.onUpdateOptions,
        isDisabled = self.isReadOnly
    }

    group:insert(title)
    group:insert(titleTipButton)
    group:insert(self.boardSizePicker:render())

    return group
end

function M:drawDictionaryOptions()
    local group = display.newGroup()

    local title = display.newText {
        text = "Special Dictionary",
        font = fonts.BOLD_FONT,
        fontSize = 50,
        x = display.contentCenterX,
        y = 450
    }
    title:setFillColor(0, 0, 0)

    local titleTipButton = tips_helpers.drawTipButton(
        "Add extra playable words to the game.\n\n" ..
        "View the special dictionary from the in-game menu.\n\n" ..
        "Earn bonus points by playing words in the dictionary.", 100, 100)
    titleTipButton.anchorX = 0
    titleTipButton.x = title.x + title.contentWidth / 2
    titleTipButton.y = title.y

    local rows = {
        {
            text1 = "None",
            text2 = "0 x",
            value = nil
        },
        {
            text1 = "Edgar Allan Poe",
            text2 = "1 x",
            value = common_api.DICT_POE
        },
        {
            text1 = "H.P. Lovecraft",
            text2 = "1 x",
            value = common_api.DICT_LOVECRAFT
        },
        {
            text1 = "Cthulhu Mythos",
            text2 = "1 x",
            value = common_api.DICT_MYTHOS
        }
    }

    local selectedIndex = nil
    for i = 1, #rows do
        local row = rows[i]
        if row.value == new_game_data.specialDict then
            selectedIndex = i
            break
        end
    end

    self.dictionaryPicker = pretty_picker.new {
        rows = rows,
        pickerY = 550,
        column1Left = LEFT_COLUMN,
        column2Left = MID_COLUMN,
        column2ImageFile = "images/currency_book.png",
        column3Center = RIGHT_COLUMN,
        bgImage = imgs.OLD_BOOK,
        bgWidth = imgs.OLD_BOOK_WIDTH,
        bgHeight = imgs.OLD_BOOK_HEIGHT,
        rowWidth = imgs.OLD_BOOK_WIDTH,
        rowHeight = 100,
        onUpdate = self.onUpdateOptions,
        isDisabled = self.isReadOnly,
        selectedIndex = selectedIndex
    }

    group:insert(title)
    group:insert(titleTipButton)
    group:insert(self.dictionaryPicker:render())

    return group
end

function M:getBoardSizeOption()
    return self.boardSizePicker:getValue()
end

function M:getDictionaryOption()
    return self.dictionaryPicker:getValue()
end

function M:getNumBlankTiles()
    return self.blankTilesStepper:getValue()
end

function M:getNumScryTiles()
    return self.scryTilesStepper:getValue()
end

function M:drawBonusOptions()
    local group = display.newGroup()
    group.y = 650

    local title = display.newText {
        text = "Bonuses",
        font = fonts.BOLD_FONT,
        fontSize = 50,
        x = display.contentCenterX
    }
    title:setFillColor(0, 0, 0)

    local titleTipButton = tips_helpers.drawTipButton(
        "Get an edge, start the game with bonus tiles!\n\n" ..
                "Question tiles can be played as any letter.\n\n" ..
                "Oracle tiles reveal a powerful move.", 100, 100)
    titleTipButton.anchorX = 0
    titleTipButton.x = title.x + title.contentWidth / 2
    titleTipButton.y = title.y

    local sheetObj = sheet_helpers:getSheetObj("rack_sheet")
    local questionIndex = sheetObj.module:getFrameIndex("?_rack")
    local scryIndex = sheetObj.module:getFrameIndex("scry_rack")
    self.blankTilesStepper = M.drawBonusOptionRow(group, "Question Tiles", 100, 4, self.onUpdateOptions, sheetObj.imageSheet, questionIndex)
    self.scryTilesStepper = M.drawBonusOptionRow(group, "Oracle Tiles", 200, 2, self.onUpdateOptions, sheetObj.imageSheet, scryIndex)

    group:insert(title)
    group:insert(titleTipButton)
    return group
end

function M.drawBonusOptionRow(parent, labelText, yPosition, maxValue, onUpdateVal, sheet, frameIndex)
    local label = display.newText {
        parent = parent,
        x = LEFT_COLUMN,
        y = yPosition,
        text = labelText,
        font = fonts.DEFAULT_FONT,
        fontSize = 44
    }
    label.anchorX = 0
    label:setFillColor(0, 0, 0)

    local stepperValue = display.newText {
        parent = parent,
        text = "0 x",
        x = MID_COLUMN - 40,
        y = yPosition,
        font = fonts.BOLD_FONT,
        fontSize = 48
    }
    stepperValue.anchorX = 0
    stepperValue:setFillColor(0, 0, 0)

    local iconImg = display.newImageRect(parent, sheet, frameIndex, 90, 90)
    iconImg.anchorX = 0
    iconImg.x = stepperValue.x + stepperValue.contentWidth + 10
    iconImg.y = yPosition

    local onPress = function(event)
        if event.phase == "increment" or event.phase == "decrement" then
           local val = event.value
           stepperValue.text = tostring(val) .. " x"
            if onUpdateVal then
                onUpdateVal(val)
            end
        end
        return true
    end

    local stepper = widget.newStepper{
        x = RIGHT_COLUMN,
        y = yPosition,
        width = 140,
        height = 70,
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
    return stepper
end


return M

