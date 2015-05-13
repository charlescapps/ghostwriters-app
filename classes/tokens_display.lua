local display = require("display")

local M = {}
local meta = { __index = M }

-- Constants
local BG_WIDTH = 650
local BG_HEIGHT = 133

local TOKEN_WIDTH = 64
local TOKEN_HEIGHT = 88

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

    --self.bg = self:drawBackground()
    --self.view:insert(self.bg)

    self:drawTokensInitially()

    return self.view
end

function M:drawBackground()
    return display.newImageRect("images/tokens_bg.png", BG_WIDTH, BG_HEIGHT)
end

function M:drawTokensInitially()
    for i = 1, self.numTokens do
        local img = display.newImageRect("images/book_token.jpg", TOKEN_WIDTH, TOKEN_HEIGHT)
        img.x, img.y = self:computeTokenPos(i)
        self.tokenImages[i] = img
        self.view:insert(img)
    end
end


function M:computeTokenPos(tokenIndex)
    local i = tokenIndex - 1
    local firstX = -257
    local x = firstX + (i % 10) * 56
    return x, -5
end


return M

