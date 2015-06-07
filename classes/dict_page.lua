local display = require("display")
local widget = require("widget")
local common_api = require("common.common_api")
local fonts = require("globals.fonts")
local math = require("math")
local json = require("json")
local transition = require("transition")

local M = {}
local meta = { __index = M }

local TABLE_WIDTH = display.contentWidth
local TABLE_HEIGHT = 900

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
    print("Rendering words played info...")
    self.wordsPlayedInfo = self:renderWordsPlayedInfo()
    print("Finished rendering words played info.")
    print("Rendering page controls...")
    self.pageControls = self:renderPageControls()
    print("Finished rendering page controls.")

    self.view:insert(self.title)
    self.view:insert(self.wordsPlayedInfo)
    self.view:insert(self.pageControls)

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
        fontSize = 48
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

    end

    local table = widget.newTableView {
        top = 300,
        x = display.contentCenterX,
        width = TABLE_WIDTH,
        height = TABLE_HEIGHT,


    }

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
    group.y = display.contentHeight - 150

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
        width = 150,
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
        width = 150,
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

