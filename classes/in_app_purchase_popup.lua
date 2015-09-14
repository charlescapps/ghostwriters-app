local display = require("display")
local common_ui = require("common.common_ui")
local transition = require("transition")
local widget = require("widget")
local pay_helpers = require("common.pay_helpers")
local fonts = require("globals.fonts")
local format_helpers = require("common.format_helpers")
local login_common = require("login.login_common")
local book_power_helpers = require("common.book_power_helpers")
local tips_helpers = require("tips.tips_helpers")
local tips_modal = require("tips.tips_modal")

local M = {}
local meta = { __index = M }

local BUTTON_SIZE = 180
local CLOSE_X_WIDTH = 90

function M.new(onRegisterPurchaseSuccess, destroyListener, numTokens, infiniteBooks)
    local popup = {
        onRegisterPurchaseSuccess = onRegisterPurchaseSuccess,
        destroyListener = destroyListener,
        numTokens = numTokens,
        infiniteBooks = infiniteBooks
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
    self.bookPowerInfo = self:drawBookPowerInfo()
    self.bookPowerTipButton = self:drawBookPowerTipButton()

    self.view:insert(self.screen)
    self.view:insert(self.background)
    self.view:insert(self.closeX)
    self.view:insert(self.title)
    if self.bookPowerInfo then
        self.view:insert(self.bookPowerInfo)
    end
    if self.bookPowerTipButton then
        self.view:insert(self.bookPowerTipButton)
    end

    -- Draw the products
    self.bookpack1_row = self:drawRow("book_pack_1", "100 books", 450, "images/book_pack1.png", "images/book_pack1_over.png")
    self.bookpack2_row = self:drawRow("book_pack_2", "225 books", 665, "images/book_pack2.png", "images/book_pack2_over.png")
    self.bookpack3_row = self:drawRow("book_pack_3", "500 books", 880, "images/book_pack3.png", "images/book_pack3_over.png")
    self.bookpack4_row = self:drawRow("infinite_books", "Infinite books", 1095, "images/book_pack_infinite.png", "images/book_pack_infinite_over.png")

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

function M:drawBookPowerInfo()
    local numTokens = self.numTokens
    if not common_ui.isValidDisplayObj(self.view) or type(numTokens) ~= "number" then
        return
    end

    local percentBonus = book_power_helpers.getBookPowerBonusFromTokens(numTokens, self.infiniteBooks)
    local color = book_power_helpers.getBookPowerColor(false, numTokens, self.infiniteBooks)

    local text = display.newText {
        x = display.contentCenterX,
        y = 300,
        text = "Book power: +" .. tostring(percentBonus) .. "% rating",
        font = fonts.BOLD_FONT,
        fontSize = 42
    }
    text:setFillColor(unpack(color))

    return text
end

function M:drawBookPowerTipButton()
    local bookPowerInfo = self.bookPowerInfo
    if not common_ui.isValidDisplayObj(bookPowerInfo) then
        return
    end

    local function onCloseFirstTip()
        local tipText = "10 books: +5% rating gain\n" ..
                "100 books: +10% rating gain\n" ..
                "250 books: +15% rating gain\n" ..
                "500 books: +20% rating gain\n\n" ..
                "Infinite books: +25% rating gain"
        local tipsModal = tips_modal.new(tipText)
        tipsModal:show()
    end

    local tipsButton = tips_helpers.drawTipButton(
        "As you accumulate books your Book Power will grow.\n\n" ..
        "With Book Power, you gain extra rating after completing games, " ..
        "helping you to climb the Leaderboard!"
        ,
        100, 100, onCloseFirstTip)
    tipsButton.anchorX = 0
    tipsButton.x = bookPowerInfo.x + bookPowerInfo.contentWidth / 2
    tipsButton.y = bookPowerInfo.y
    return tipsButton
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
    common_ui.safeRemove(self.bookPowerInfo)
    common_ui.safeRemove(self.bookPowerTipButton)

    self.title = self:drawTitle()


    self.bookPowerInfo = self:drawBookPowerInfo()
    self.bookPowerTipButton = self:drawBookPowerTipButton()

    if self.title then
        self.view:insert(self.title)
    end
    if self.bookPowerInfo then
        self.view:insert(self.bookPowerInfo)
    end
    if self.bookPowerTipButton then
        self.view:insert(self.bookPowerTipButton)
    end
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

