local display = require("display")
local widget = require("widget")
local game_ui = require("common.game_ui")
local stepper_sheet = require("spritesheets.stepper_sheet")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local fonts = require("globals.fonts")
local new_game_data = require("globals.new_game_data")
local sheet_helpers = require("globals.sheet_helpers")
local tips_helpers = require("tips.tips_helpers")

local choose_board_size_modal = require("classes.choose_board_size_modal")
local choose_special_dict_modal = require("classes.choose_special_dict_modal")

local M = {}

local LEFT_COLUMN = 75
local MID_COLUMN = display.contentCenterX + 50
local RIGHT_COLUMN = display.contentWidth - 110

local BOOKMARK_WIDTH = 800
local BOOKMARK_HEIGHT = 125

local QUESTION_TILE_TIP = "Question Tiles can be played as any letter.\n\n" ..
                          "Worth the full points of the chosen letter!"

local ORACLE_TILE_TIP = "Oracle Tiles find a powerful move for you.\n\n" ..
                        "The move is placed on the board, and you can choose to play the move or not."

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
    group.y = 500

    local bg = display.newImageRect("images/bookmark1.png", BOOKMARK_WIDTH, BOOKMARK_HEIGHT)
    bg.x, bg.y = display.contentCenterX, 0

    local title = display.newText {
        text = "GAME SIZE",
        font = fonts.BOLD_FONT,
        fontSize = 40,
        x = 25,
        y = 0
    }
    title.anchorX = 0
    title:setFillColor(1, 1, 1)

    local function onRelease()
        local function onSelect(boardSize)
            if not self.chooseBoardSizeButton then
                return
            end
            local newLabel = self:boardSizeToDisplayText(boardSize)
            self.chooseBoardSizeButton:setLabel(newLabel)
            new_game_data.boardSize = boardSize
            if type(self.onUpdateOptions) == "function" then
                self.onUpdateOptions()
            end
        end
        if common_ui.isValidDisplayObj(self.view) then
            local modal = choose_board_size_modal.new(onSelect, self.isReadOnly, new_game_data.boardSize)
            self.view:toFront()
            self.view:insert(modal:show())
        end
    end

    local boardSizeText = self:boardSizeToDisplayText(new_game_data.boardSize)
    self.chooseBoardSizeButton = widget.newButton {
        width = 175,
        height = 80,
        x = MID_COLUMN,
        y = 0,
        label = boardSizeText,
        labelColor = { default={ 1, 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 40,
        font = fonts.DEFAULT_FONT,
        shape = "roundedRect",
        fillColor = { default={ 0.5, 0.5, 0.5, 1 }, over={ 0.2, 0.2, 0.2, 1 } },
        strokeColor = { default={ 1, 1, 1, 1 }, over={ 0.6, 0.6, 0.6, 1 } },
        strokeWidth = 3,
        cornerRadius = 25,
        onRelease = onRelease
    }

    local titleTipButton = tips_helpers.drawTipButton(
        "Choose the board size.\n\n" ..
        "The larger the board, the more your rating increases for winning games.", 100, 100)
    titleTipButton.anchorX = 1
    titleTipButton.x = RIGHT_COLUMN
    titleTipButton.y = 0

    group:insert(bg)
    group:insert(title)
    group:insert(self.chooseBoardSizeButton)
    group:insert(titleTipButton)

    return group
end

function M:boardSizeToDisplayText(boardSize)
    if boardSize == common_api.SMALL_SIZE then
        return "5 x 5"
    elseif boardSize == common_api.MEDIUM_SIZE then
        return "9 x 9"
    elseif boardSize == common_api.LARGE_SIZE then
        return "13 x 13"
    end
    print("ERROR - invalid board size in create_game_options:" .. tostring(boardSize))
end

function M:drawDictionaryOptions()
    local group = display.newGroup()
    group.y = 650

    local bg = display.newImageRect("images/bookmark2.png", BOOKMARK_WIDTH, BOOKMARK_HEIGHT)
    bg.x, bg.y = display.contentCenterX, 0

    local title = display.newText {
        text = "BONUS WORDS",
        font = fonts.BOLD_FONT,
        fontSize = 40,
        x = 25,
        y = 0
    }
    title.anchorX = 0
    title:setFillColor(1, 1, 1)

    local function onRelease()
        local function onSelect(specialDict)
            if not self.chooseDictButton then
                return
            end
            local newLabel = self:dictToLabel(specialDict)
            self.chooseDictButton:setLabel(newLabel)
            new_game_data.specialDict = specialDict
            if type(self.onUpdateOptions) == "function" then
                self.onUpdateOptions()
            end
        end
        if common_ui.isValidDisplayObj(self.view) then
            local modal = choose_special_dict_modal.new(onSelect, self.isReadOnly, new_game_data.specialDict)
            self.view:toFront()
            self.view:insert(modal:show())
        end
    end

    local dictionaryLabel = self:dictToLabel(new_game_data.specialDict)
    self.chooseDictButton = widget.newButton {
        width = 175,
        height = 80,
        x = display.contentCenterX + 50,
        y = 0,
        label = dictionaryLabel,
        labelColor = { default={ 1, 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 40,
        font = fonts.DEFAULT_FONT,
        shape = "roundedRect",
        fillColor = { default={ 0.5, 0.5, 0.5, 1 }, over={ 0.2, 0.2, 0.2, 1 } },
        strokeColor = { default={ 1, 1, 1, 1 }, over={ 0.6, 0.6, 0.6, 1 } },
        strokeWidth = 3,
        cornerRadius = 25,
        onRelease = onRelease
    }

    local titleTipButton = tips_helpers.drawTipButton(
        "Add extra playable words to the game for both players.\n\n" ..
        "View the special dictionary from the in-game menu.\n\n" ..
        "Earn bonus points by playing words in the dictionary.", 100, 100)
    titleTipButton.anchorX = 1
    titleTipButton.x = RIGHT_COLUMN
    titleTipButton.y = 0

    group:insert(bg)
    group:insert(title)
    group:insert(self.chooseDictButton)
    group:insert(titleTipButton)

    return group
end

function M:dictToLabel(specialDict)
    if specialDict == nil then
        return "None"
    elseif specialDict == common_api.DICT_LOVECRAFT then
        return "H.P.L."
    elseif specialDict == common_api.DICT_POE then
        return "Poe"
    elseif specialDict == common_api.DICT_MYTHOS then
        return "Cthulhu"
    end
    print("ERROR - Invalid specialDcit in create_game_options: " .. tostring(specialDict))
end

function M:getNumBlankTiles()
    return self.blankTilesStepper:getValue()
end

function M:getNumScryTiles()
    return self.scryTilesStepper:getValue()
end

function M:drawBonusOptions()
    local group = display.newGroup()
    group.y = 800

    local sheetObj = sheet_helpers:getSheetObj("rack_sheet")
    local questionIndex = sheetObj.module:getFrameIndex("question_rack")
    local scryIndex = sheetObj.module:getFrameIndex("scry_rack")
    self.blankTilesStepper = M.drawBonusOptionRow(group, "Question Tiles", 0, 4, self.onUpdateOptions, sheetObj.imageSheet, questionIndex, "images/bookmark1.png", QUESTION_TILE_TIP)
    self.scryTilesStepper = M.drawBonusOptionRow(group, "Oracle Tiles", 150, 4, self.onUpdateOptions, sheetObj.imageSheet, scryIndex, "images/bookmark2.png", ORACLE_TILE_TIP)

    return group
end

function M.drawBonusOptionRow(parent, labelText, yPosition, maxValue, onUpdateVal, sheet, frameIndex, bgImage, tipText)

    local bg = display.newImageRect(bgImage, BOOKMARK_WIDTH, BOOKMARK_HEIGHT)
    bg.x = display.contentWidth / 2
    bg.y = yPosition
    parent:insert(bg)

    local stepperValue = display.newText {
        text = "0 x",
        x = LEFT_COLUMN,
        y = yPosition,
        font = fonts.BOLD_FONT,
        fontSize = 48
    }
    stepperValue.anchorX = 0
    stepperValue:setFillColor(1, 1, 1)
    parent:insert(stepperValue)

    local iconImg = display.newImageRect(sheet, frameIndex, 90, 90)
    iconImg.anchorX = 0
    iconImg.x = stepperValue.x + stepperValue.contentWidth + 10
    iconImg.y = yPosition
    parent:insert(iconImg)

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
        x = MID_COLUMN,
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

    local tipButton = tips_helpers.drawTipButton(tipText, 100, 100)
    tipButton.anchorX = 1
    tipButton.x = RIGHT_COLUMN
    tipButton.y = yPosition
    parent:insert(tipButton)

    return stepper
end


return M

