local display = require("display")
local common_ui = require("common.common_ui")
local math = require("math")
local widget = require("widget")
local in_app_purchase_popup = require("classes.in_app_purchase_popup")

local M = {}
local meta = { __index = M }

-- Constants
local MAX_TOKENS = 10

local ALL_TOKENS_WIDTH = 550

local TOKEN_WIDTH = 100
local TOKEN_HEIGHT = 100

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

    self.tokensGroup = self:drawTokens()

    self.view:insert(self.tokensGroup)

    return self.view
end

function M:addTouchListener(group)
    local function onRelease()
        if not self.view then
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

    function group:touch(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            onRelease()
        elseif event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end

    function group:tap(event)
        return true
    end

    group:addEventListener("touch")
    group:addEventListener("tap")
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

    self:addTouchListener(tokensGroup)

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
    self.tokensGroup, self.backgroundSmoke = self:drawTokens()

    if self.backgroundSmoke then
        self.view:insert(self.backgroundSmoke)
    end
    self.view:insert(self.tokensGroup)

end

function M:removeAllImages()
    common_ui.safeRemove(self.tokensGroup)
    self.tokensGroup = nil

    common_ui.safeRemove(self.backgroundSmoke)
    self.backgroundSmoke = nil

    self.tokenImages = {}

end

return M

