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
    self.noneButton = self:drawButton("None (Standard English)", nil,
        "images/choose_none_button_default.png", "images/choose_none_button_over.png", 190, display.contentCenterY - 400)

    self.poeButton = self:drawButton("Edgar Allan Poe", common_api.DICT_POE,
        "images/choose_poe_button_default.png", "images/choose_poe_button_over.png", 190, display.contentCenterY - 150)

    self.lovecraftButton = self:drawButton("H.P. Lovecraft", common_api.DICT_LOVECRAFT,
        "images/choose_lovecraft_button_default.png", "images/choose_lovecraft_button_over.png", 190, display.contentCenterY + 100)

    self.cthulhuButton = self:drawButton("Cthulhu Mythos", common_api.DICT_MYTHOS,
        "images/choose_cthulhu_button_default.png", "images/choose_cthulhu_button_over.png", 190, display.contentCenterY + 350)

    -- Insert display objects
    self.view:insert(self.screen)
    self.view:insert(self.bg)
    self.view:insert(self.noneButton)
    self.view:insert(self.poeButton)
    self.view:insert(self.lovecraftButton)
    self.view:insert(self.cthulhuButton)

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
        y = button.y + button.contentHeight / 2
    }
    label.anchorY = 0

    group:insert(button)
    group:insert(label)

    return group
end

return M

