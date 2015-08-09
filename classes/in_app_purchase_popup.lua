local display = require("display")
local common_ui = require("common.common_ui")
local transition = require("transition")
local widget = require("widget")
local pay_helpers = require("common.pay_helpers")
local fonts = require("globals.fonts")
local format_helpers = require("common.format_helpers")
local login_common = require("login.login_common")

local M = {}
local meta = { __index = M }

local BUTTON_SIZE = 180
local CLOSE_X_WIDTH = 90

function M.new(onRegisterPurchaseSuccess, destroyListener, numTokens)
    local popup = {
        onRegisterPurchaseSuccess = onRegisterPurchaseSuccess,
        destroyListener = destroyListener,
        numTokens = numTokens
    }
    print("Creating new in-app purchase popup")
    pay_helpers.registerAllPurchases()
    return setmetatable(popup, meta)
end

function M:render()
    print("Rendering in-app purchase pop-up")
    self.view = display.newGroup()
    self.view.alpha = 0

    self.screen = self:drawScreen()
    self.background = self:drawBackground()
    self.closeX = self:drawCloseX()
    self.title = self:drawTitle()

    self.view:insert(self.screen)
    self.view:insert(self.background)
    self.view:insert(self.closeX)
    self.view:insert(self.title)

    -- Draw the products
    self.bookpack1_row = self:drawRow("book_pack_1", "100 books", 375, "images/book_pack1.png", "images/book_pack1_over.png")
    self.bookpack2_row = self:drawRow("book_pack_2", "225 books", 600, "images/book_pack2.png", "images/book_pack2_over.png")
    self.bookpack3_row = self:drawRow("book_pack_3", "500 books", 825, "images/book_pack3.png", "images/book_pack3_over.png")
    self.bookpack4_row = self:drawRow("infinite_books", "Infinite books", 1050, "images/book_pack_infinite.png", "images/book_pack_infinite_over.png")

    self.view:insert(self.bookpack1_row)
    self.view:insert(self.bookpack2_row)
    self.view:insert(self.bookpack3_row)
    self.view:insert(self.bookpack4_row)

    return self.view
end

function M:drawTitle()
    local numTokens = self.numTokens
    local tokenStr
    if type(numTokens) ~= "number" then
        tokenStr = "???"
    else
        tokenStr = format_helpers.comma_value(numTokens)
    end

    local titleText = "You have " .. tokenStr .. " books"

    local textObj = display.newText {
        text = titleText,
        x = display.contentCenterX,
        y = 225,
        align = "center",
        font = fonts.BOLD_FONT,
        fontSize = 48
    }
    textObj:setFillColor(0, 0, 0)

    return textObj
end

function M:setNumTokens(numTokens)
    if type(numTokens) ~= "number" then
        return
    end
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end
    self.numTokens = numTokens
    common_ui.safeRemove(self.title)
    self.title = self:drawTitle()
    self.view:insert(self.title)
end

function M:drawBackground()
    local bg = display.newImageRect("images/purchase_modal_bg.png", 750, 1175)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    bg:addEventListener("touch", function(event)
        return true
    end)

    bg:addEventListener("tap", function(event)
        return true
    end)
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

function M:drawCloseX()
    local function onRelease()
        self:destroy()
    end
    local x = display.contentCenterX - self.background.contentWidth / 2 + CLOSE_X_WIDTH + 20
    local y = display.contentCenterY - self.background.contentHeight / 2 + CLOSE_X_WIDTH
    local closeX = widget.newButton {
        x = x,
        y = y,
        width = CLOSE_X_WIDTH,
        height = CLOSE_X_WIDTH,
        defaultFile = "images/close_x_default.png",
        overFile = "images/close_x_over.png",
        onRelease = onRelease
    }
    return closeX
end

function M:drawRow(productIdentifier, text, y, buttonImgDefault, buttonImgOver)
    local group = display.newGroup()
    group.y = y

    local text = display.newText {
        text = text,
        font = fonts.BOLD_FONT,
        fontSize = 48,
        x = 100,
        y = 0
    }
    text.anchorX = 0
    text:setFillColor(0, 0, 0)

    local function getOnReleaseListener(productName)
        return function()
            print("Clicked button to purchase product: '" .. tostring(productName) .. "'")
            local function myOnRegisterSuccess()
                self.onRegisterPurchaseSuccess()
                local updatedUser = login_common.getUser()
                if updatedUser and type(updatedUser.tokens) == "number" then
                   self:setNumTokens(updatedUser.tokens)
                end
            end
            pay_helpers.purchase(productName, myOnRegisterSuccess)
        end
    end

    local button = widget.newButton {
        defaultFile = buttonImgDefault,
        overFile = buttonImgOver,
        width = BUTTON_SIZE,
        height = BUTTON_SIZE,
        onRelease = getOnReleaseListener(productIdentifier)
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

    if self.destroyListener then
        self.destroyListener()
    end
end


return M

