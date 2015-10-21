local common_ui = require("common.common_ui")
local display = require("display")
local transition = require("transition")
local widget = require("widget")
local fonts = require("globals.fonts")
local composer = require("composer")
local tips_helpers = require("tips.tips_helpers")
local login_common = require("login.login_common")
local user_info_popup = require("classes.user_info_popup")
local prefs = require("prefs.prefs")
local sheet_helpers = require("globals.sheet_helpers")
local music = require("common.music")

local M = {}
local meta = { __index = M }

local BOOK_POPUP_WIDTH = 750
local BOOK_POPUP_HEIGHT = 1024

local CLOSE_X_WIDTH = 90

function M.new()
    local userOptionsMenu = {}
    return setmetatable(userOptionsMenu, meta)
end

function M:render()
    self.view = display.newGroup()
    self.view.alpha = 0

    self.screen = self:drawScreen()
    self.background = self:drawBackground()
    self.myStatsButton = self:drawMyStatsButton()
    self.musicOptionRow = self:createMusicOptionRow()
    self.soundOptionRow = self:createSoundOptionRow()

    self.setPasswordButton = self:drawSetPasswordButton()
    self.setPasswordTipButton = self:drawSetPasswordTipButton()
    self.logoutButton = self:drawLogoutButton()
    self.logoutTipButton = self:drawLogoutTipButton()

    self.closeX = self:drawCloseX()

    self.view:insert(self.screen)
    self.view:insert(self.background)
    self.view:insert(self.myStatsButton)
    self.view:insert(self.musicOptionRow)
    self.view:insert(self.soundOptionRow)
    self.view:insert(self.setPasswordButton)
    self.view:insert(self.setPasswordTipButton)
    self.view:insert(self.logoutButton)
    self.view:insert(self.logoutTipButton)
    self.view:insert(self.closeX)

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

function M:drawMyStatsButton()
    local function onRelease()
        local user = login_common.getUser()
        if not user then
            return
        end
        local userInfoPopup = user_info_popup.new(user, nil, user, false)
        local view = userInfoPopup:render()
        userInfoPopup:show()
    end

    return self:drawOptionButton("My Record", display.contentCenterY - 300, onRelease)
end

function M:createMusicOptionRow()
    local Y_POS = display.contentCenterY - 150
    local group = display.newGroup()
    local musicOptionText = display.newEmbossedText {
        text = "Music On",
        font = fonts.DEFAULT_FONT,
        fontSize = 60,
        width = 450,
        align = "center"
    }
    musicOptionText:setFillColor(1, 1, 1)
    musicOptionText.x = display.contentCenterX
    musicOptionText.y = Y_POS

    local wasSoundEnabled = prefs.getPref(prefs.PREF_MUSIC)
    local checkboxSheetObj = sheet_helpers:getSheetObj("checkboxes_sheet")
    local sheet = checkboxSheetObj.imageSheet
    local module = checkboxSheetObj.module

    local function onReleaseCheckbox(event)
        if event and event.target and event.target.isOn then
            prefs.savePref(prefs.PREF_MUSIC, true)
        else
            prefs.savePref(prefs.PREF_MUSIC, false)
            music.stopMusic()
        end
    end

    local musicCheckbox = widget.newSwitch {
        initialSwitchState = wasSoundEnabled,
        style = "checkbox",
        sheet = sheet,
        width = 80,
        height = 80,
        frameOn = module:getFrameIndex("checkbox_checked"),
        frameOff = module:getFrameIndex("checkbox_unchecked"),
        x = musicOptionText.x + musicOptionText.contentWidth / 2 + 10,
        y = Y_POS,
        onRelease = onReleaseCheckbox
    }
    musicCheckbox.anchorX = 0

    group:insert(musicOptionText)
    group:insert(musicCheckbox)

    return group
end

function M:createSoundOptionRow()
    local Y_POS = display.contentCenterY
    local group = display.newGroup()
    local soundOptionTextView = display.newEmbossedText {
        text = "Sounds On",
        font = fonts.DEFAULT_FONT,
        fontSize = 60,
        width = 450,
        align = "center"
    }
    soundOptionTextView:setFillColor(1, 1, 1)
    soundOptionTextView.x = display.contentCenterX
    soundOptionTextView.y = Y_POS

    local wasSoundEnabled = prefs.getPref(prefs.PREF_SOUND)
    local checkboxSheetObj = sheet_helpers:getSheetObj("checkboxes_sheet")
    local sheet = checkboxSheetObj.imageSheet
    local module = checkboxSheetObj.module

    local function onReleaseCheckbox(event)
        if event and event.target and event.target.isOn then
            prefs.savePref(prefs.PREF_SOUND, true)
        else
            prefs.savePref(prefs.PREF_SOUND, false)
        end
    end

    local soundCheckbox = widget.newSwitch {
        initialSwitchState = wasSoundEnabled,
        style = "checkbox",
        sheet = sheet,
        width = 80,
        height = 80,
        frameOn = module:getFrameIndex("checkbox_checked"),
        frameOff = module:getFrameIndex("checkbox_unchecked"),
        x = soundOptionTextView.x + soundOptionTextView.contentWidth / 2 + 10,
        y = Y_POS,
        onRelease = onReleaseCheckbox
    }
    soundCheckbox.anchorX = 0

    group:insert(soundOptionTextView)
    group:insert(soundCheckbox)

    return group
end

function M:drawSetPasswordButton()
    local function onRelease()
        composer.gotoScene("scenes.set_password_scene", "fade")
    end

    return self:drawOptionButton("Set password", display.contentCenterY + 150, onRelease)
end

function M:drawSetPasswordTipButton()
    local tipsButton = tips_helpers.drawTipButton(
        "Set a password so you can login as the same player on another device.\n\n" ..
        "Make sure you never lose access to your account!",
        100, 100)
    local b = self.setPasswordButton
    tipsButton.x = b.x + b.contentWidth/2 + tipsButton.width/2
    tipsButton.y = b.y

    return tipsButton
end

function M:drawLogoutButton()
    local function onRelease()
        login_common.logout()
    end

    return self:drawOptionButton("Logout", display.contentCenterY + 300, onRelease)
end

function M:drawLogoutTipButton()
    local tipsButton = tips_helpers.drawTipButton(
        "Logout so you can login as a user from another device.\n\n" ..
        "Don't worry, you can always log back in as the user you created with this device.",
        100, 100)
    local b = self.logoutButton
    tipsButton.x = b.x + b.contentWidth/2 + tipsButton.width/2
    tipsButton.y = b.y

    return tipsButton
end

function M:drawCloseX()
    local function onRelease()
        self:destroy()
        music.playTitleMusic()
    end
    local x = CLOSE_X_WIDTH + 20
    local y = display.contentCenterY - self.background.contentHeight / 2 + CLOSE_X_WIDTH + 20
    local closeX = widget.newButton {
        x = x,
        y = y,
        width = CLOSE_X_WIDTH,
        height = CLOSE_X_WIDTH,
        defaultFile = "images/close_x_default.png",
        overFile = "images/close_x_over.png",
        onRelease = onRelease
    }
    self.view:insert(closeX)
    return closeX
end

return M

