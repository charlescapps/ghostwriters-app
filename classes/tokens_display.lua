local display = require("display")
local common_ui = require("common.common_ui")
local math = require("math")
local pay_helpers = require("common.pay_helpers")
local table = require("table")

local M = {}
local meta = { __index = M }

-- Constants
local BG_WIDTH = 650
local BG_HEIGHT = 133

local ALL_TOKENS_WIDTH = 500

local TOKEN_WIDTH = 90
local TOKEN_HEIGHT = 90

local PLUS_WIDTH = 100
local PLUS_HEIGHT = 100

local DISPLAY_TOKEN_WIDTH = ALL_TOKENS_WIDTH / pay_helpers.MAX_TOKENS  -- 50

function M.new(x, y, numTokens)
    local tokensDisplay = {
        x = x,
        y = y,
        numTokens = numTokens,
        tokenImages = {}
    }

    print("Created tokens_display with numTokens = " .. tostring(tokensDisplay.numTokens))
    print("type(numTokens)=" .. type(tokensDisplay.numTokens))

    return setmetatable(tokensDisplay, meta)

end

function M:render()
    local group = display.newGroup()
    group.x, group.y = self.x, self.y
    self.view = group
    self:addTouchListener(group)
    --self.bg = self:drawBackground()
    --self.view:insert(self.bg)

    self:drawTokens()

    self.plusIcon = self:drawPlusIcon()
    self.view:insert(self.plusIcon)

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

function M:drawBackground()
    return display.newImageRect("images/tokens_bg.png", BG_WIDTH, BG_HEIGHT)
end

function M:drawPlusIcon()
    local imgFile = self.numTokens > pay_helpers.MAX_TOKENS and "images/plus_icon.png"
        or "images/plus_icon_hidden.png"

    print("Plus icon file=" .. imgFile)

    local img = display.newImageRect(imgFile, PLUS_WIDTH, PLUS_HEIGHT)
    img.x = ALL_TOKENS_WIDTH / 2 + 32
    return img
end

function M:drawTokens()
    for i = 1, math.min(pay_helpers.MAX_TOKENS, self.numTokens) do
        local img = display.newImageRect("images/currency_book.png", TOKEN_WIDTH, TOKEN_HEIGHT)
        img.x, img.y = self:computeTokenPos(i)
        self.tokenImages[i] = img
        self.view:insert(img)
    end

    for i = self.numTokens + 1, pay_helpers.MAX_TOKENS do
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

function M:updateNumTokens(updatedNumTokens)
    print("Updating tokens in tokens_display to: " .. tostring(updatedNumTokens))
    if updatedNumTokens == self.numTokens then
        return
    end
    if not self.view then
        return
    end
    self:removeAllImages()
    self.numTokens = updatedNumTokens
    self:drawTokens()
    self.plusIcon = self:drawPlusIcon()
    self.view:insert(self.plusIcon)
end

function M:removeAllImages()
    while #self.tokenImages > 0 do
        local img = self.tokenImages[1]
        table.remove(self.tokenImages, 1)
        img:removeSelf()
    end
    
    self.plusIcon:removeSelf()
    self.plusIcon = nil
end

return M

