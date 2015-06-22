local display = require("display")
local common_ui = require("common.common_ui")
local math = require("math")
local table = require("table")
local widget = require("widget")
local in_app_purchase_popup = require("classes.in_app_purchase_popup")

local M = {}
local meta = { __index = M }

-- Constants
local MAX_TOKENS = 10

local BG_WIDTH = 650
local BG_HEIGHT = 133

local ALL_TOKENS_WIDTH = 500

local TOKEN_WIDTH = 90
local TOKEN_HEIGHT = 90

local PLUS_WIDTH = 75
local PLUS_HEIGHT = 75

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
    self:addTouchListener(group)

    self:drawTokens()

    self.purchaseButton = self:drawPurchaseButton()
    self.view:insert(self.purchaseButton)

    return self.view
end

function M:addTouchListener(group)
    local tokensDisplay = self
    function group:touch(event)
        if event.phase == "began" then

        elseif event.phase == "ended" then
            common_ui.createInfoModal("", "You own " .. tostring(tokensDisplay.numTokens) .. " books.", nil, nil, 50)
        elseif event.phase == "cancelled" then
        end
    end

    group:addEventListener("touch")
end

function M:drawPurchaseButton()
    local function onRelease()
        if not self.view then
            return
        end
        local user = self.authUser
        if not user then
            return
        end
        if user.infiniteBooks then
            common_ui.createInfoModal("Infinite Books!", "You have infinite books, no need to purchase anything!")
            return
        end
        local popup = in_app_purchase_popup.new(self.updateUserListener)
        self.parentScene.view:insert(popup:render())
        popup:show()
    end

    local button = widget.newButton {
        width = PLUS_WIDTH,
        height = PLUS_HEIGHT,
        x = ALL_TOKENS_WIDTH / 2 + 32,
        y = 0,
        defaultFile = "images/purchase_button_default.png",
        overFile = "images/purchase_button_over.png",
        onRelease = onRelease
    }
    return button
end

function M:drawTokens()
    for i = 1, math.min(MAX_TOKENS, self.numTokens) do
        local img = display.newImageRect("images/currency_book.png", TOKEN_WIDTH, TOKEN_HEIGHT)
        img.x, img.y = self:computeTokenPos(i)
        self.tokenImages[i] = img
        self.view:insert(img)
    end

    for i = self.numTokens + 1, MAX_TOKENS do
        local img = display.newImageRect("images/currency_book.png", TOKEN_WIDTH, TOKEN_HEIGHT)
        img.x, img.y = self:computeTokenPos(i)
        img:setFillColor(1, 1, 1, 0.5)
        self.tokenImages[i] = img
        self.view:insert(img)
    end
end

function M:computeTokenPos(tokenIndex)
    local i = tokenIndex - 1
    local firstX = -ALL_TOKENS_WIDTH / 2
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

    if not self.view then
        return
    end

    self:removeAllImages()
    self.numTokens = updatedUser.tokens
    self:drawTokens()
    self.purchaseButton = self:drawPurchaseButton()
    self.view:insert(self.purchaseButton)
end

function M:removeAllImages()
    while #self.tokenImages > 0 do
        local img = self.tokenImages[1]
        table.remove(self.tokenImages, 1)
        img:removeSelf()
    end
    
    self.purchaseButton:removeSelf()
    self.purchaseButton = nil
end

return M

