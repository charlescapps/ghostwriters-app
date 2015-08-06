local display = require("display")
local transition = require("transition")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local widget = require("widget")
local fonts = require("globals.fonts")

local M = {}
local meta = { __index = M }

function M.new(onSelect)
    local modal = {
        onSelect = onSelect
    }

    return setmetatable(modal, meta)
end

function M:show()
    self.view = display.newGroup()
    self.view.alpha = 0
    self.bg = self:drawBg()
    self.screen = self:drawScreen()
    self.smallButton = self:drawButton("Short Story (5 x 5)", common_api.SMALL_SIZE,
        "images/small_board.png", "images/small_board_over.png", 200, display.contentCenterY - 385)

    self.mediumButton = self:drawButton("Novel (9 x 9)", common_api.MEDIUM_SIZE,
        "images/medium_board.png", "images/medium_board_over.png", 235, display.contentCenterY - 60)

    self.largeButton = self:drawButton("Tome (13 x 13)", common_api.LARGE_SIZE,
        "images/large_board.png", "images/large_board_over.png", 270, display.contentCenterY + 290)

    -- Insert display objects
    self.view:insert(self.screen)
    self.view:insert(self.bg)
    self.view:insert(self.smallButton)
    self.view:insert(self.mediumButton)
    self.view:insert(self.largeButton)

    -- Fade in
    transition.fadeIn(self.view, { time = 800 })

    return self.view
end

function M:drawBg()
    local img = display.newImageRect("images/old_book.png", 750, 1067)
    img.x = display.contentCenterX
    img.y = display.contentCenterY
    return img
end

function M:drawScreen()
    local screen = common_ui:drawScreen()
    return screen
end

function M:close()
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end

    local function onComplete()
        common_ui.safeRemove(self.view)
    end

    transition.fadeOut(self.view, { time = 800 })
end

function M:drawButton(labelText, callbackValue, defaultImg, overImg, width, yPos)
    local group = display.newGroup()

    local function onRelease()
        if type(self.onSelect) == "function" then
            self:close()
            self.onSelect(callbackValue)
        end
    end
    local button = widget.newButton {
        defaultFile = defaultImg,
        overFile = overImg,
        width = width,
        height = width,
        x = display.contentCenterX,
        y = yPos,
        onRelease = onRelease
    }

    local label = display.newText {
        text = labelText,
        font = fonts.BOLD_FONT,
        fontSize = 40,
        x = display.contentCenterX,
        y = button.y + button.contentHeight / 2 + 5
    }
    label.anchorY = 0

    group:insert(button)
    group:insert(label)

    return group
end

return M

