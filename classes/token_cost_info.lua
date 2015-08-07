local display = require("display")
local fonts = require("globals.fonts")
local transition = require("transition")

local M = {}
local meta = { __index = M }

function M.new(x, y, initialCost)
    local tokenCostInfo = {
        x = x,
        y = y,
        cost = initialCost
    }

    return setmetatable(tokenCostInfo, meta)
end

function M:render()
    self.view = display.newGroup()
    self.view.x, self.view.y = self.x, self.y

    self.title = self:drawTitle()
    self.view:insert(self.title)

    self.tokenSymbol = self:drawTokenSymbol()
    self.view:insert(self.tokenSymbol)

    return self.view
end

function M:drawTitle()
    local title = display.newText {
        x = -45,
        y = 0,
        text = "Books to play = " .. self.cost .. " x",
        font = fonts.BOLD_FONT,
        fontSize = 48,
        align = "right"
    }
    title:setFillColor(0, 0, 0)

    return title
end

function M:drawTokenSymbol()
    local img = display.newImageRect("images/currency_book.png", 90, 90)
    img.x, img.y = self.title.x + self.title.contentWidth / 2, 0
    img.anchorX = 0
    return img
end

function M:updateCost(cost)
    self.cost = cost
    local newTitle = self:drawTitle()
    local oldTitle = self.title
    newTitle.alpha = 0
    self.view:insert(newTitle)
    transition.fadeIn(newTitle, { time = 300 })
    self.title = newTitle

    local function removeOldTitle()
        if oldTitle and oldTitle.removeSelf then
            transition.cancel(oldTitle)
            oldTitle:removeSelf()
        end
    end

    if oldTitle and oldTitle.removeSelf then
        transition.fadeOut(oldTitle, { time = 300, onComplete = removeOldTitle, onCancel = removeOldTitle})
    end
end

return M
