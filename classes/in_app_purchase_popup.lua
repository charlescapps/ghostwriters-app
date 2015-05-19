local display = require("display")
local transition = require("transition")
local native = require("native")
local widget = require("widget")

local M = {}
local meta = { __index = M }

local BUTTON_SIZE = 200

function M.new()
    local popup = {
    }
    print("Creating new in-app purchase popup")
    return setmetatable(popup, meta)
end

function M:render()
    print("Rendering in-app purchase pop-up")
    self.view = display.newGroup()
    self.view.alpha = 0

    self.screen = self:drawScreen()
    self.background = self:drawBackground()

    self.view:insert(self.screen)
    self.view:insert(self.background)

    -- Draw the products
    self.bookpack1_row = self:drawRow("10 books", 300, "images/book_pack1.png", "images/book_pack1_over.png")
    self.bookpack2_row = self:drawRow("25 books", 550, "images/book_pack2.png", "images/book_pack2_over.png")
    self.bookpack3_row = self:drawRow("60 books", 800, "images/book_pack3.png", "images/book_pack3_over.png")
    self.bookpack4_row = self:drawRow("Infinite books", 1050, "images/book_pack_infinite.png", "images/book_pack_infinite_over.png")

    self.view:insert(self.bookpack1_row)
    self.view:insert(self.bookpack2_row)
    self.view:insert(self.bookpack3_row)
    self.view:insert(self.bookpack4_row)

    return self.view
end

function M:drawBackground()
    local bg = display.newImageRect("images/purchase_modal_bg.png", 750, 1100)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    return bg
end

function M:drawScreen()
    local screen = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    screen:setFillColor(0, 0, 0, 0.5)
    local popup = self

    screen:addEventListener("touch", function(event)
        if event.phase == "began" then
           display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            popup:destroy()
        elseif event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end)

    screen:addEventListener("tap", function(event)
        return true
    end)

    return screen
end

function M:drawRow(text, y, buttonImgDefault, buttonImgOver, productName)
    local group = display.newGroup()
    group.y = y

    local text = display.newText {
        text = text,
        font = native.systemFontBold,
        fontSize = 40,
        x = 100,
        y = 0
    }
    text.anchorX = 0
    text:setFillColor(0, 0, 0)

    local button = widget.newButton {
        defaultFile = buttonImgDefault,
        overFile = buttonImgOver,
        width = BUTTON_SIZE,
        height = BUTTON_SIZE
    }
    button.x = 525
    button.y = 0

    group:insert(text)
    group:insert(button)

    return group
end

function M:show()
    transition.fadeIn(self.view, { time = 1000 })
end

function M:destroy()
    local function onComplete()
        if self.view and self.view.removeSelf then
            self.view:removeSelf()
        end
    end

    transition.fadeOut(self.view, {
        time = 700,
        onComplete = onComplete,
        onCancel = onComplete
    })
end


return M

