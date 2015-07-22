local common_ui = require("common.common_ui")
local display = require("display")
local fonts = require("globals.fonts")
local transition = require("transition")
local timer = require("timer")

local M = {}
local meta = { __index = M }

function M.new(user, fontSize, onClose)
    local challengedPopup = {
        user = user,
        fontSize = fontSize or 48,
        onClose = onClose,
    }

    challengedPopup = setmetatable(challengedPopup, meta)
    challengedPopup:render()

    return challengedPopup
end

function M:render()
    self.view = display.newGroup()
    self.view.alpha = 0
    local screen = common_ui.drawScreen()
    self.bg = self:drawBackground()
    self.title = self:drawTitle()
    self.usernameText = self:drawText()
    local headImg = self:drawHeadImage()
    local secondHeadImg = self:drawSecondHeadImage()
    local userStats = self:drawUserStats()

    self.view:insert(screen)
    self.view:insert(self.bg)
    self.view:insert(self.title)
    self.view:insert(self.usernameText)
    self.view:insert(headImg)
    self.view:insert(secondHeadImg)
    self.view:insert(userStats)
end

function M:show()
    transition.fadeIn(self.view, {
        time = 1000
    })

    timer.performWithDelay(4000, function()
        self:destroy()
    end)
end

function M:destroy()
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end

    if self.fadeOutTransition then
        return
    end

    local function onComplete()
        common_ui.safeRemove(self.view)

        if self.onClose and not self.hasDoneOnClose then
            self.hasDoneOnClose = true
            self.onClose()
        end
    end

    self.fadeOutTransition = transition.fadeOut(self.view, {
        time = 1000,
        onComplete = onComplete,
        onCancel = onComplete
    })
end

function M:drawBackground()
    local bg = display.newImageRect("images/scroll_background.png", 750, 857)
    bg.x, bg.y = display.contentCenterX, display.contentCenterY

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

    bg:addEventListener("touch", onTouch)

    return bg
end

function M:drawTitle()
    local title = display.newText {
        text = "Challenging",
        x = display.contentCenterX,
        y = display.contentCenterY - 250,
        width = 600,
        align = "center",
        font = fonts.BOLD_FONT,
        fontSize = 64
    }

    return title
end

function M:drawText()
    local text = display.newText {
        text = self.user.username,
        x = display.contentCenterX,
        y = self.title.y + self.title.contentHeight / 2 + 30,
        width = 750,
        align = "center",
        font = fonts.DEFAULT_FONT,
        fontSize = self.fontSize
    }
    text.anchorY = 0
    return text
end

function M:drawHeadImage()
    local img = display.newImageRect("images/head_lovecraft.png", 300, 350)
    img.x, img.y = display.contentCenterX - 150, display.contentCenterY - 425
    return img
end

function M:drawSecondHeadImage()
    local img = display.newImageRect("images/head_poe.png", 300, 350)
    img.x, img.y = display.contentCenterX + 150, display.contentCenterY - 425
    return img
end

function M:drawUserStats()
    local group = display.newGroup()

    local rating, wins, losses, ties = self.user.rating, self.user.wins, self.user.losses, self.user.ties

    if rating == nil or wins == nil or losses == nil or ties == nil then
        return group
    end

    local ratingTitle, ratingText = self:drawRow("Rating", tostring(rating), self.usernameText, 50)
    local winsTitle, winsText = self:drawRow("Wins", tostring(wins), ratingTitle, 10)
    local lossesTitle, lossesText = self:drawRow("Losses", tostring(losses), winsTitle, 10)
    local tiesTitle, tiesText = self:drawRow("Ties", tostring(ties), lossesTitle, 10)

    group:insert(ratingTitle)
    group:insert(ratingText)
    group:insert(winsTitle)
    group:insert(winsText)
    group:insert(lossesTitle)
    group:insert(lossesText)
    group:insert(tiesTitle)
    group:insert(tiesText)

    return group
end

function M:drawRow(rowTitle, rowText, prevRowTitle, padding)
    local myY = prevRowTitle.y + prevRowTitle.contentHeight + padding

    local title = display.newText {
        text = rowTitle,
        font = fonts.BOLD_FONT,
        fontSize = 42,
        x = display.contentCenterX - 15,
        y = myY
    }

    title.anchorY = 0
    title.anchorX = 1

    local text = display.newText {
        text = rowText,
        font = fonts.DEFAULT_FONT,
        fontSize = 42,
        x = display.contentCenterX + 15,
        y = title.y + title.contentHeight / 2
    }

    text.anchorY = 0.5
    text.anchorX = 0

    return title, text
end

return M

