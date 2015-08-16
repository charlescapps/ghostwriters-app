local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local display = require("display")
local transition = require("transition")
local easing = require("easing")
local fonts = require("globals.fonts")
local json = require("json")
local sound = require("common.sound")

local M = {}
local meta = { __index = M }

local POE_TEXT_COLOR = { 0.73, 0.89, 0.89 }
local LOVECRAFT_TEXT_COLOR = { 0.83, 0.78, 0.71 }
local MYTHOS_TEXT_COLOR = { 0.655, 0.706, 0.665 }

function M.new(specialDict, word, isCurrentPlayer, onModalClose)
    local bonusPopup = {
        specialDict = specialDict,
        word = word,
        isCurrentPlayer = isCurrentPlayer,
        onModalClose = onModalClose
    }

    print("Created new bonus_popup: " .. json.encode(bonusPopup))

    return setmetatable(bonusPopup, meta)
end

function M:render()
    self.view = display.newGroup()
    self.view.x = 0
    self.view.y = display.contentHeight -- begin out of view.

    local textColor = self:getTextColor()

    self.background = self:drawBackground()
    self.whoPlayedText = self:drawWhoPlayed(textColor)
    self.titleText = self:drawTitleText(textColor)
    self.bonusPointsText = self:drawBonusPointsText(textColor)
    self.button = self:drawButton()

    self.view:insert(self.background)
    self.view:insert(self.whoPlayedText)
    self.view:insert(self.titleText)
    self.view:insert(self.bonusPointsText)
    self.view:insert(self.button)

    return self.view
end

function M:drawBackground()
    local imgFile = self:getImageFile()
    local img = display.newImageRect(imgFile, display.contentWidth, display.contentHeight)
    img.x, img.y = display.contentCenterX, display.contentCenterY
    return img
end

function M:show()
    local function onComplete()
        self:playSound()
    end
    if self.view then
        transition.to(self.view, { y = 0, time = 1000, transition = easing.outBack, onComplete = onComplete })
    end
end

function M:destroy()
    local oldView = self.view
    local onModalClose = self.onModalClose
    if oldView then
        local function onComplete()
            if oldView and oldView.removeSelf then
                oldView:removeSelf()
                if onModalClose then
                    onModalClose()
                end
            end
        end
       transition.to(oldView, { y = display.contentHeight, time = 1000, onComplete = onComplete, onCancel = onComplete })
    end
end

function M:getImageFile()
    if self.specialDict == common_api.DICT_POE then
        return "images/bonus_poe.jpg"
    elseif self.specialDict == common_api.DICT_LOVECRAFT then
        return "images/bonus_lovecraft.jpg"
    elseif self.specialDict == common_api.DICT_MYTHOS then
        return "images/bonus_mythos.jpg"
    end
end

function M:playSound()
    if self.specialDict == common_api.DICT_POE then
        sound.playRavensSound()
    elseif self.specialDict == common_api.DICT_LOVECRAFT then
    elseif self.specialDict == common_api.DICT_MYTHOS then
    end
end

function M:drawWhoPlayed(textColor)
    local noun = self.isCurrentPlayer and "You" or "They"
    local text = display.newText {
        text = noun .. " played",
        x = display.contentCenterX,
        y = display.contentCenterY + 75,
        width = display.contentWidth,
        align = "center",
        font = fonts.DEFAULT_FONT,
        fontSize = 64
    }
    text:setFillColor(textColor[1], textColor[2], textColor[3])

    return text
end

function M:drawTitleText(textColor)
    local title = display.newText {
        text = self.word,
        x = display.contentCenterX,
        y = display.contentCenterY + 175,
        width = display.contentWidth,
        align = "center",
        font = fonts.BOLD_FONT,
        fontSize = 64
    }
    title:setFillColor(textColor[1], textColor[2], textColor[3])

    return title
end

function M:drawBonusPointsText(textColor)
    local bonusPts = common_api.getBonusPoints(self.specialDict)
    local bonusText = display.newText {
        text = "+" .. tostring(bonusPts) .. " points",
        x = display.contentCenterX,
        y = display.contentCenterY + 275,
        width = display.contentWidth,
        align = "center",
        font = fonts.DEFAULT_FONT,
        fontSize = 64
    }
    bonusText:setFillColor(textColor[1], textColor[2], textColor[3])

    return bonusText
end

function M:drawButton()
    local text = self:getButtonText()
    local function onRelease()
        self:destroy()
        return true
    end

    local button = common_ui.createButton(text, display.contentHeight - 200, onRelease, 500)

    return button
end

function M:getTextColor()
    if self.specialDict == common_api.DICT_POE then
        return POE_TEXT_COLOR
    elseif self.specialDict == common_api.DICT_LOVECRAFT then
        return LOVECRAFT_TEXT_COLOR
    elseif self.specialDict == common_api.DICT_MYTHOS then
        return MYTHOS_TEXT_COLOR
    end
end

function M:getButtonText()
    if self.specialDict == common_api.DICT_POE then
        return "How fustian!"
    elseif self.specialDict == common_api.DICT_LOVECRAFT then
        return "Eldritch"
    elseif self.specialDict == common_api.DICT_MYTHOS then
        return "Cthulhu fhtagn!"
    end
end

return M
