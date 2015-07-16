local common_ui = require("common.common_ui")
local display = require("display")
local transition = require("transition")
local widget = require("widget")
local fonts = require("globals.fonts")
local composer = require("composer")
local tips_helpers = require("tips.tips_helpers")
local login_common = require("login.login_common")

local M = {}
local meta = { __index = M }

local BOOK_POPUP_WIDTH = 750
local BOOK_POPUP_HEIGHT = 1024

function M.new()
    local userOptionsMenu = {}
    return setmetatable(userOptionsMenu, meta)
end

function M:render()
    self.view = display.newGroup()
    self.view.alpha = 0

    self.screen = self:drawScreen()
    self.background = self:drawBackground()
    self.setPasswordButton = self:drawSetPasswordButton()
    self.setPasswordTipButton = self:drawSetPasswordTipButton()
    self.logoutButton = self:drawLogoutButton()
    self.logoutTipButton = self:drawLogoutTipButton()

    self.view:insert(self.screen)
    self.view:insert(self.background)
    self.view:insert(self.setPasswordButton)
    self.view:insert(self.setPasswordTipButton)
    self.view:insert(self.logoutButton)
    self.view:insert(self.logoutTipButton)

    return self.view
end

function M:show()
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end

    transition.fadeIn(self.view, { time = 1000 })
end

function M:destroy()
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end

    local function onComplete()
        common_ui.safeRemove(self.view)
    end

    transition.fadeOut(self.view, { time = 800, onComplete = onComplete, onCancel = onComplete })
end

function M:drawScreen()
    local screen = common_ui.drawScreen()

    local function onTouch(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            self:destroy()
        elseif event.phase == "cancelled" then
           display.getCurrentStage():setFocus(nil)
        end
        return true
    end

    local function onTap(event)
        return true
    end

    screen:addEventListener("touch", onTouch)
    screen:addEventListener("tap", onTap)

    return screen
end

function M:drawBackground()
    local background = display.newImageRect("images/book_popup.jpg", BOOK_POPUP_WIDTH, BOOK_POPUP_HEIGHT)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local function onTouch(event)
        return true
    end

    local function onTap(event)
        return true
    end

    background:addEventListener("touch", onTouch)
    background:addEventListener("tap", onTap)

    return background
end

function M:drawOptionButton(text, y, onRelease)
    local labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 1, 1, 1 } }
    local fillColor = { default={ 1, 1, 1, 0 }, over={ 1, 1, 1, 0.3 } }
    local strokeColor = { default={ 0, 0, 0, 0.5 }, over={ 0, 0, 0, 1 } }
    local optionButton = widget.newButton {
        label = text,
        onRelease = onRelease,
        labelColor = labelColor,
        font = fonts.DEFAULT_FONT,
        fontSize = 60,
        shape = "roundedRect",
        fillColor = fillColor,
        strokeColor = strokeColor,
        cornerRadius = 20,
        width = 450,
        height = 150
    }

    optionButton.x = display.contentCenterX
    optionButton.y = y

    return optionButton
end

function M:drawSetPasswordButton()
    local function onRelease()
        composer.gotoScene("scenes.set_password_scene", "fade")
    end

    return self:drawOptionButton("Set a password", display.contentCenterY - 150, onRelease)
end

function M:drawSetPasswordTipButton()
    local tipsButton = tips_helpers.drawTipButton(
        "Set a password so you can login as the same player on another device.\n\n" ..
        "Make sure you never lose access to your account!",
        75, 75)
    local b = self.setPasswordButton
    tipsButton.x = b.x + b.contentWidth/2 + tipsButton.width/2
    tipsButton.y = b.y

    return tipsButton
end

function M:drawLogoutButton()
    local function onRelease()
        login_common.logout()
    end

    return self:drawOptionButton("Logout", display.contentCenterY, onRelease)
end

function M:drawLogoutTipButton()
    local tipsButton = tips_helpers.drawTipButton(
        "Logout so you can login as a user from another device.",
        75, 75)
    local b = self.logoutButton
    tipsButton.x = b.x + b.contentWidth/2 + tipsButton.width/2
    tipsButton.y = b.y

    return tipsButton
end

return M

