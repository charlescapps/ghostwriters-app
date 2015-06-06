local display = require("display")
local widget = require("widget")
local common_api = require("common.common_api")
local fonts = require("globals.fonts")
local math = require("math")

local M = {}
local meta = { __index = M }

local TABLE_WIDTH = display.contentWidth
local TABLE_HEIGHT = 900

function M.new(startY, specialDict, words, pageNum, totalPages, numPlayed, totalWords)
    local dictPage = {
        startY = startY,
        specialDict = specialDict,
        words = words,
        pageNum = pageNum,
        totalPages = totalPages,
        numPlayed = numPlayed,
        totalWords = totalWords
    }

    return setmetatable(dictPage, meta)
end

function M:render()
    self.view = display.newGroup()
    self.title = self:renderTitle()
    self.wordsPlayedInfo = self:renderWordsPlayedInfo()
    self.pageControls = self:renderPageControls()

    self.view:insert(self.title)
    self.view:insert(self.wordsPlayedInfo)
    self.view:insert(self.pageControls)

    return self.view
end

function M:renderTitle()
    local title = display.newText {
        x = display.contentCenterX,
        y = 100,
        text = self:getTitleText(self.specialDict),
        width = 700,
        height = 200,
        align = "center",
        font = fonts.BOLD_FONT,
        fontSize = 48
    }
    title:setFillColor(0, 0, 0)

    return title
end

function M:renderWordsPlayedInfo()
    local infoText = display.newText {
        x = 0,
        y = 250,
        text = self:getWordsPlayedText(),
        width = 700,
        align = "center"
    }
    infoText:setFillColor(0, 0, 0)
    return infoText
end

function M:getWordsPlayedText()
    local percent = math.floor(self.numPlayed / self.totalWords)
    return "You have played " .. self.numPlayed .. " / " .. self.totalWords .. " words (" .. percent .. "%)"
end

function M:renderWordsTable()
    local function onRowRender(event)

    end

    local table = widget.newTableView {
        top = self.startY,
        x = display.contentCenterX,
        width = TABLE_WIDTH,
        height = TABLE_HEIGHT,


    }
end

function M:renderPageControls()
    local group = display.newGroup()
    group.y = display.contentHeight - 50

    local pageNums = display.newText {
        x = 0,
        y = 0,
        text = self.pageNum .. " of " .. self.totalPages,
        font = fonts.DEFAULT_FONT,
        fontSize = 20,
        align = "center"
    }
    pageNums:setFillColor(0, 0, 0)

    local leftArrow = widget.newButton {
        x = -200,
        defaultFile = "images/left_arrow_default.png",
        overFile = "images/left_arrow_over.png",
        width = 150,
        height = 75,
        isEnabled = self.pageNum > 1
    }

    if self.pageNum == 1 then
        leftArrow:setFillColor(0.5, 0.5, 0.5)
    end

    local rightArrow = widget.newButton {
        x = 200,
        defaultFile = "images/right_arrow_default.png",
        overFile = "images/right_arrow_over.png",
        width = 150,
        height = 75,
        isEnabled = self.pageNum < self.totalPages
    }

    if self.pageNum == self.totalPages then
        rightArrow:setFillColor(0.5, 0.5, 0.5)
    end

    group:insert(pageNums)
    group:insert(leftArrow)
    group:insert(rightArrow)

    return group
end

function M:getTitleText(specialDict)
    if specialDict == common_api.DICT_POE then
        return "The words of Edgar Allan Poe"
    elseif specialDict == common_api.DICT_LOVECRAFT then
        return "The words of H.P. Lovecraft"
    elseif specialDict == common_api.DICT_MYTHOS then
        return "Cthulhu Mythos"
    end
end

return M

