local display = require("display")
local common_ui = require("common.common_ui")
local in_app_purchase_popup = require("classes.in_app_purchase_popup")
local graphics = require("graphics")
local math = require("math")
local widget = require("widget")

local M = {}
local meta = { __index = M }

-- Constants
local MAX_TOKENS = 10

local ALL_TOKENS_WIDTH = 575

local TOKEN_WIDTH = 100
local TOKEN_HEIGHT = 100

local TOP_BOOKSHELF_WIDTH = 650
local TOP_BOOKSHELF_HEIGHT = 114

local BOTTOM_BOOKSHELF_HEIGHT = 136
local BOTTOM_BOOKSHELF_WIDTH = 650

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

    self.topBookshelf = self:drawTopBookshelf()
    self.tokensGroup = self:drawTokens()

    self.bookshelfMeter = self:drawBookshelfMeter()

    self.view:insert(self.topBookshelf)
    self.view:insert(self.tokensGroup)
    self.view:insert(self.bookshelfMeter)

    return self.view
end

function M:drawTopBookshelf()
    local bg = widget.newButton {
        defaultFile = "images/top_bookshelf.png",
        overFile = "images/top_bookshelf_over.png",
        width = TOP_BOOKSHELF_WIDTH,
        height = TOP_BOOKSHELF_HEIGHT,
        onRelease = function() self:openInAppPurchasePopup() end,
        x = 0,
        y = 0
    }
    return bg
end

function M:drawBookshelfMeter()
    local group = display.newGroup()
    group.x, group.y = 0, TOP_BOOKSHELF_HEIGHT / 2 + BOTTOM_BOOKSHELF_HEIGHT / 2

    local bg = widget.newButton {
        defaultFile = "images/bookshelf_bg_meter.png",
        overFile = "images/bookshelf_bg_meter_over.png",
        width = BOTTOM_BOOKSHELF_WIDTH,
        height = BOTTOM_BOOKSHELF_HEIGHT,
        onRelease = function() self:openInAppPurchasePopup() end,
        x = 0,
        y = 0
    }

    local fill = display.newImageRect("images/bookshelf_fill_meter.png", BOTTOM_BOOKSHELF_WIDTH, BOTTOM_BOOKSHELF_HEIGHT)
    self.bookshelfFill = fill


    local mask
    if display.imageSuffix == "@2x" then
        mask = graphics.newMask("images/bookshelf_meter_mask@2x.png")
    else
        mask = graphics.newMask("images/bookshelf_meter_mask.png")
    end
    fill:setMask(mask)

    local currentProgress = self:getBottomShelfProgress()
    self:setBottomShelfProgressDisplay(currentProgress)

    group:insert(bg)
    group:insert(fill)
    return group
end

function M:setBottomShelfProgressDisplay(progress)
    if not self.bookshelfFill or not common_ui.isValidDisplayObj(self.bookshelfFill) then
        return
    end

    self.bookshelfFill.maskX = -BOTTOM_BOOKSHELF_WIDTH / 2 + progress * BOTTOM_BOOKSHELF_WIDTH

end

function M:getBottomShelfProgress()
    local n = self.numTokens
    if not n or n <= 10 then
        return 0
    end

    if n > 10 and n <= 100 then
       return 0.25 * (100 - n) / (100 - 10)
    end

    if n > 100 and n <= 250 then
        return 0.25 + 0.25 * (250 - n) / (250 - 100)
    end

    if n > 250 and n <= 500 then
        return 0.5 + 0.25 * (500 - n) / (500 - 250)
    end

    local MAX = 999999

    return math.min(1, 0.75 + (MAX - n) / (MAX - 500))
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
    local popup = in_app_purchase_popup.new(self.updateUserListener, self.updateUserListener)
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

    self.view:insert(self.tokensGroup)

end

function M:removeAllImages()
    common_ui.safeRemove(self.tokensGroup)
    self.tokensGroup = nil

    common_ui.safeRemove(self.bookshelfMeter)
    self.bookshelfMeter, self.bookshelfFill = nil, nil

    self.tokenImages = {}

end

return M

