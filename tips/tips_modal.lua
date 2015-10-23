local common_ui = require("common.common_ui")
local display = require("display")
local fonts = require("globals.fonts")
local transition = require("transition")

local M = {}
local meta = {__index = M}

function M.new(text, fontSize, onClose, imgFile, imgWidth, imgHeight, imgX, imgY)
    local tipsModal = {
        text = text,
        fontSize = fontSize or 40,
        onClose = onClose,
        imgFile = imgFile,
        imgWidth = imgWidth,
        imgHeight = imgHeight,
        imgX = imgX or 0,
        imgY = imgY or 0
    }

    tipsModal = setmetatable(tipsModal, meta)
    tipsModal:render()

    return tipsModal
end

function M:render()
    self.view = display.newGroup()
    self.view.alpha = 0
    local screen = common_ui.drawScreen()
    self.bg = self:drawBackground()
    self.title = self:drawTitle()
    local tipText = self:drawText()
    local button = self:drawButton()
    local headImg = self:drawHeadImage()

    self.view:insert(screen)
    self.view:insert(self.bg)
    self.view:insert(self.title)
    self.view:insert(tipText)
    self.view:insert(button)
    self.view:insert(headImg)

    if self.imgFile then
        self.tipImage = self:drawTipImage()
        self.view:insert(self.tipImage)
    end

end

function M:show()
    transition.fadeIn(self.view, {
        time = 500
    })
end

function M:destroy()
    if not self.view or not self.view.removeSelf then
        return
    end

    local function onComplete()
        if self.view and self.view.removeSelf then
            self.view:removeSelf()
        end
    end

    transition.fadeOut(self.view, {
        time = 500,
        onComplete = onComplete,
        onCancel = onComplete
    })
end

function M:drawTipImage()
    local img = display.newImageRect(self.imgFile, self.imgWidth, self.imgHeight)
    img.x = display.contentCenterX + self.imgX
    img.y = display.contentCenterY + self.imgY
    return img
end

function M:drawBackground()
    local bg = display.newImageRect("images/scroll_background.png", 750, 857)
    bg.x, bg.y = display.contentCenterX, display.contentCenterY
    return bg
end

function M:drawTitle()
    local title = display.newText {
        text = "Tip",
        x = display.contentCenterX,
        y = display.contentCenterY - 350,
        width = 600,
        align = "center",
        font = fonts.BOLD_FONT,
        fontSize = 75
    }

    return title
end

function M:drawText()
    local tipText = display.newText {
        text = self.text,
        x = display.contentCenterX,
        y = self.title.y + self.title.contentHeight / 2 + 25,
        width = 500,
        height = 800,
        align = "left",
        font = fonts.DEFAULT_FONT,
        fontSize = self.fontSize
    }
    tipText.anchorY = 0
    return tipText
end

function M:drawButton()
    local function onRelease()
        if self.onClose then
            self.onClose()
        end
        self:destroy()
    end
    local button = common_ui.createButton("Got it!", display.contentCenterY + 175, onRelease, 350, 90)
    return button
end

function M:drawHeadImage()
    local img = display.newImageRect("images/head_lovecraft.png", 300, 350)
    img.x, img.y = display.contentCenterX - 150, display.contentCenterY - 400
    return img
end

return M

