local display = require("display")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local in_app_purchase_popup = require("classes.in_app_purchase_popup")
local graphics = require("graphics")
local math = require("math")
local widget = require("widget")
local fonts = require("globals.fonts")

local M = {}
local meta = { __index = M }

-- Constants
local MAX_TOKENS = 10

local ALL_TOKENS_WIDTH = 575

local TOKEN_WIDTH = 100
local TOKEN_HEIGHT = 100

local BOTTOM_BOOKSHELF_HEIGHT = 136
local BOTTOM_BOOKSHELF_WIDTH = 650

local BACKGROUND_WIDTH = 650
local BACKGROUND_HEIGHT = 254

local DISPLAY_TOKEN_WIDTH = ALL_TOKENS_WIDTH / MAX_TOKENS  -- 50

function M.new(parentScene, x, y, authUser, updateUserListener)
    local tokensDisplay = {
        parentScene = parentScene,
        x = x,
        y = y,
        numTokens = authUser.tokens,
        tokenImages = {},
        authUser = authUser,
        updateUserListener = updateUserListener
    }

    print("Created tokens_display with numTokens = " .. tostring(tokensDisplay.numTokens))

    return setmetatable(tokensDisplay, meta)
end

function M:render()
    local group = display.newGroup()
    group.x, group.y = self.x, self.y
    self.view = group

    self.background = self:drawBackground()
    self.tokensGroup = self:drawTokens()
    self.bookshelfMeter = self:drawBookshelfMeter()
    self.numberIndicators = self:drawNumberIndicators()

    self.view:insert(self.background)
    self.view:insert(self.tokensGroup)
    self.view:insert(self.bookshelfMeter)
    if self.numberIndicators then
        self.view:insert(self.numberIndicators)
    end

    local currentProgress = self:getBottomShelfProgress()
    self:setBottomShelfProgressDisplay(currentProgress)

    return self.view
end

function M:drawBookshelfMeter()
    local meter = display.newImageRect("images/bookshelf_fill_meter.png", BOTTOM_BOOKSHELF_WIDTH, BOTTOM_BOOKSHELF_HEIGHT)
    meter.x, meter.y = 0, BACKGROUND_HEIGHT / 2 - 8

    local mask
    if display.imageSuffix == "@2x" then
        print("Using @2x bookshelf mask image...")
        mask = graphics.newMask("images/bookshelf_meter_mask@2x.png")
    else
        print("Using normal bookshelf mask image...")
        mask = graphics.newMask("images/bookshelf_meter_mask.png")
    end
    meter:setMask(mask)

    return meter
end

function M:drawNumberIndicators()
    if not common_ui.isValidDisplayObj(self.bookshelfMeter) or
       not common_ui.isValidDisplayObj(self.tokensGroup) then
        print("Error - display objects not valid, not drawing number indicators")
        return
    end

    if type(self.numTokens) ~= "number" then
        return
    end

    local meterY = self.bookshelfMeter.y
    local group = display.newGroup()

    if self.numTokens >= 10 then
        group:insert(self:drawNumber("10", 560 - BACKGROUND_WIDTH / 2, 0))
    end

    if self.numTokens >= 100 then
        group:insert(self:drawNumber("100", 60 - BACKGROUND_WIDTH / 2, meterY))
    end

    if self.numTokens >= 250 then
       group:insert(self:drawNumber("250", 220 - BACKGROUND_WIDTH / 2, meterY))
    end

    if self.numTokens >= 500 then
       group:insert(self:drawNumber("500", 385 - BACKGROUND_WIDTH / 2, meterY))
    end

    if self.authUser and self.authUser.infiniteBooks then
       group:insert(self:drawNumber("∞", 535 - BACKGROUND_WIDTH / 2, meterY, 85))
    end

    return group
end

function M:drawNumber(num, x, y, fontSize)
    print("drawing number indicator: " .. num .. ", x = " .. tostring(x) .. ", y = " .. tostring(y))
    local text = display.newText {
        text = num,
        x = x,
        y = y,
        font = fonts.BOLD_FONT,
        fontSize = fontSize or 48
    }
    text.x, text.y = x, y
    text.anchorX = 0
    return text
end

function M:drawBackground()
    local bg = widget.newButton {
        defaultFile = "images/bookshelf_background.png",
        overFile = "images/bookshelf_background_over.png",
        width = BACKGROUND_WIDTH,
        height = BACKGROUND_HEIGHT,
        onRelease = function() self:openInAppPurchasePopup() end,
        x = 0,
        y = BACKGROUND_HEIGHT / 4
    }
    return bg
end

function M:setBottomShelfProgressDisplay(progress)
    if not common_ui.isValidDisplayObj(self.bookshelfMeter) then
        return
    end

    print("Setting progress to: " .. tostring(progress))

    self.bookshelfMeter.maskX = -BOTTOM_BOOKSHELF_WIDTH / 2 + progress * BOTTOM_BOOKSHELF_WIDTH

end

function M:getBottomShelfProgress()
    if self.authUser and self.authUser.infiniteBooks then
        return 1
    end

    local n = self.numTokens
    if type(n) ~= "number" or n <= 10 then
        return 0
    end

    if n > 10 and n <= 100 then
       return 0.25 * (n - 10) / (100 - 10)
    end

    if n > 100 and n <= 250 then
        return 0.25 + 0.25 * (n - 100) / (250 - 100)
    end

    if n > 250 and n <= 500 then
        return 0.5 + 0.25 * (n - 250) / (500 - 250)
    end

    local MAX = common_api.MAX_BOOK_TOKENS

    return math.min(1, 0.75 + 0.25 * (n - 500) / (MAX - 500))
end

function M:openInAppPurchasePopup()
    if not common_ui.isValidDisplayObj(self.view) then
        return true
    end
    local user = self.authUser
    if not user then
        return true
    end
    if user.infiniteBooks then
        common_ui.createInfoModal("Infinite Books!", "You have infinite books, no need to purchase anything!")
        return true
    end
    local popup = in_app_purchase_popup.new(self.updateUserListener, self.updateUserListener, self.numTokens)
    self.parentScene.view:insert(popup:render())
    popup:show()
    return true
end


function M:drawTokens()
    local tokensGroup = display.newGroup()

    for i = 1, math.min(MAX_TOKENS, self.numTokens) do
        local img = display.newImageRect("images/currency_book.png", TOKEN_WIDTH, TOKEN_HEIGHT)
        img.x, img.y = self:computeTokenPos(i)
        self.tokenImages[i] = img
        tokensGroup:insert(img)
    end

    for i = self.numTokens + 1, MAX_TOKENS do
        local img = display.newImageRect("images/currency_book.png", TOKEN_WIDTH, TOKEN_HEIGHT)
        img.x, img.y = self:computeTokenPos(i)
        img:setFillColor(1, 1, 1, 0.5)
        self.tokenImages[i] = img
        tokensGroup:insert(img)
    end

    return tokensGroup
end

function M:computeTokenPos(tokenIndex)
    local i = tokenIndex - 1
    local firstX = -ALL_TOKENS_WIDTH / 2 + DISPLAY_TOKEN_WIDTH / 2
    local x = firstX + (i % 10) * DISPLAY_TOKEN_WIDTH
    return x, 0
end

function M:updateUser(updatedUser)
    if not updatedUser then
        return
    end
    self.authUser = updatedUser
    print("Updating tokens in tokens_display to: " .. tostring(updatedUser.tokens))
    if updatedUser.tokens == self.numTokens then
        return
    end

    if not common_ui.isValidDisplayObj(self.view) then
        return
    end

    self:removeAllImages()
    self.numTokens = updatedUser.tokens
    self.tokensGroup = self:drawTokens()
    self.bookshelfMeter = self:drawBookshelfMeter()
    self.numberIndicators = self:drawNumberIndicators()

    self.view:insert(self.tokensGroup)
    self.view:insert(self.bookshelfMeter)
    if self.numberIndicators then
        self.view:insert(self.numberIndicators)
    end

    local currentProgress = self:getBottomShelfProgress()
    self:setBottomShelfProgressDisplay(currentProgress)
end

function M:removeAllImages()
    common_ui.safeRemove(self.tokensGroup)
    self.tokensGroup = nil

    common_ui.safeRemove(self.bookshelfMeter)
    self.bookshelfMeter = nil

    common_ui.safeRemove(self.numberIndicators)
    self.numberIndicators = nil

    self.tokenImages = {}

end

return M

