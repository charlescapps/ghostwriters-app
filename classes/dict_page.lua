local display = require("display")
local widget = require("widget")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local fonts = require("globals.fonts")
local math = require("math")
local json = require("json")
local transition = require("transition")

local M = {}
local meta = { __index = M }

local TABLE_WIDTH = display.contentWidth - 50
local TABLE_HEIGHT = 900

local ROW_HEIGHT = 75
local EVEN_ROW_COLOR = { over = { 0.46, 0.78, 1.0, 0.2 }, default = { 0.46, 0.78, 1.0, 0.6 } }
local ODD_ROW_COLOR =  { over = { 0.87, 0.95, 1.0, 0.2 }, default = { 0.67, 0.75, 0.8, 0.6 } }

function M.new(specialDict, words, pageNum, totalPages, numPlayed, totalWords, onReleaseNextPage, onReleasePrevPage)
    local dictPage = {
        specialDict = specialDict,
        words = words,
        pageNum = pageNum,
        totalPages = totalPages,
        numPlayed = numPlayed,
        totalWords = totalWords,
        onReleaseNextPage = onReleaseNextPage,
        onReleasePrevPage = onReleasePrevPage
    }

    print("Created DictPage = " .. json.encode(dictPage))

    return setmetatable(dictPage, meta)
end

function M:render()
    self.view = display.newGroup()
    self.title = self:renderTitle()
    self.wordsPlayedInfo = self:renderWordsPlayedInfo()
    self.pageControls = self:renderPageControls()
    self.wordsTable = self:renderWordsTable()

    self.view:insert(self.title)
    self.view:insert(self.wordsPlayedInfo)
    self.view:insert(self.pageControls)
    self.view:insert(self.wordsTable)

    return self.view
end

function M:renderTitle()
    local title = display.newText {
        x = display.contentCenterX,
        y = 200,
        text = self:getTitleText(self.specialDict),
        width = 500,
        height = 200,
        align = "center",
        font = fonts.BOLD_FONT,
        fontSize = 52
    }
    title:setFillColor(0, 0, 0)

    return title
end

function M:renderWordsPlayedInfo()
    local infoText = display.newText {
        x = display.contentCenterX,
        y = 200,
        text = self:getWordsPlayedText(),
        width = 700,
        align = "center",
        font = fonts.DEFAULT_FONT,
        fontSize = 32
    }
    infoText:setFillColor(0, 0, 0)
    return infoText
end

function M:getWordsPlayedText()
    local percent = math.floor(self.numPlayed * 100 / self.totalWords)
    return "You have played " .. tostring(self.numPlayed) .. " / " .. tostring(self.totalWords) .. " words (" .. tostring(percent) .. "%)"
end

function M:renderWordsTable()
    local function onRowRender(event)
        local row = event.row
        local word = row.params.word
        local wordText = display.newText {
            text = word.w,
            x = 50,
            y = row.height / 2,
            align = "left",
            fontSize = 40,
            font = fonts.DEFAULT_FONT

        }
        wordText:setFillColor(0, 0, 0)
        wordText.anchorX = 0

        if word.d then
           local defLink = display.newText {
               text = "def.",
               x = 50 + wordText.contentWidth + 25,
               y = row.height / 2,
               align = "left",
               fontSize = 40,
               font = fonts.BOLD_FONT
           }
           defLink:setFillColor(0, 0.6, 0)
           defLink.anchorX = 0

           local function onTouch(event)
               local phase = event.phase

               if "began" == phase then
                   display.getCurrentStage():setFocus(event.target)
               elseif "ended" == phase then
                   display.getCurrentStage():setFocus(nil)
                   common_ui.createInfoModal(word.w, word.d, nil, nil, nil, {1, 1, 1}, "images/book_popup.jpg", 750, 1024, 50, -300, "left", 550)
               elseif "cancelled" == phase then
                   display.getCurrentStage():setFocus(nil)
               end
               return true
           end

            row:addEventListener("touch", onTouch)
            row:insert(defLink)
        end

        if word.p then
            local check = display.newImageRect("images/check.png", row.height - 20, row.height - 20)
            check.x = row.width - 100
            check.y = row.height / 2

            row:insert(check)
        end

        row:insert(wordText)
    end

    local table = widget.newTableView {
        top = 250,
        x = display.contentCenterX,
        width = TABLE_WIDTH,
        height = TABLE_HEIGHT,
        isLocked = true,
        noLines = true,
        hideBackground = true,
        onRowRender = onRowRender
    }

    for i = 1, #self.words do
       table:insertRow {
           rowHeight = 75,
           rowColor = i % 2 == 0 and EVEN_ROW_COLOR or ODD_ROW_COLOR,
           params = { word = self.words[i] }
       }

    end

    return table
end

function M:disableArrows()
    local pageControls = self.pageControls
    if pageControls then
        if pageControls.leftArrow then
            pageControls.leftArrow:setEnabled(false)
            pageControls.rightArrow:setEnabled(false)
        end
    end
end

function M:renderPageControls()
    local group = display.newGroup()
    group.x = display.contentCenterX
    group.y = display.contentHeight - 120

    local pageNums = display.newText {
        x = 0,
        y = 0,
        text = self.pageNum .. " of " .. self.totalPages,
        font = fonts.BOLD_FONT,
        fontSize = 40,
        align = "center"
    }
    pageNums:setFillColor(0, 0, 0)

    local leftArrow = widget.newButton {
        x = -200,
        y = 0,
        defaultFile = "images/left_arrow_default.png",
        overFile = "images/left_arrow_over.png",
        width = 130,
        height = 75,
        isEnabled = self.pageNum > 1,
        onRelease = self.onReleasePrevPage
    }

    if self.pageNum == 1 then
        leftArrow:setFillColor(0.5, 0.5, 0.5)
    end

    local rightArrow = widget.newButton {
        x = 200,
        y = 0,
        defaultFile = "images/right_arrow_default.png",
        overFile = "images/right_arrow_over.png",
        width = 130,
        height = 75,
        isEnabled = self.pageNum < self.totalPages,
        onRelease = self.onReleaseNextPage
    }

    if self.pageNum == self.totalPages then
        rightArrow:setFillColor(0.5, 0.5, 0.5)
    end

    group.leftArrow = leftArrow
    group.rightArrow = rightArrow

    group:insert(pageNums)
    group:insert(leftArrow)
    group:insert(rightArrow)

    return group
end

function M:getTitleText(specialDict)
    if specialDict == common_api.DICT_POE then
        return "Edgar Allan Poe"
    elseif specialDict == common_api.DICT_LOVECRAFT then
        return "H.P. Lovecraft"
    elseif specialDict == common_api.DICT_MYTHOS then
        return "Cthulhu Mythos"
    end
end

function M:destroy()
    if self.view and self.view.removeSelf then
        local oldView = self.view
        local function onComplete()
            if oldView and oldView.removeSelf then
                oldView:removeSelf()
            end
        end
        transition.fadeOut(oldView, {
            time = 1000,
            onComplete = onComplete,
            onCancel = onComplete
        })
    end
end

return M

