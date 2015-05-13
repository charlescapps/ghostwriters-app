local display = require("display")
local native = require("native")
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
        x = 100,
        y = 0,
        text = "Cost = " .. self.cost .. " x ",
        font = native.systemFontBold,
        fontSize = 48,
        align = "right"
    }
    title.anchorX = 1.0
    title:setFillColor(0, 0, 0)

    return title
end

function M:drawTokenSymbol()
    local img = display.newImageRect("images/book_token.jpg", 64, 88)
    img.x, img.y = 130, 0
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
        transition.fadeOut(oldTitle, { time = 300, onComplete = removeOldTitle, onCancelled = removeOldTitle})
    end
end

return M
