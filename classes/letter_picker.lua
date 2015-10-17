local common_ui = require("common.common_ui")
local display = require("display")
local fonts = require("globals.fonts")
local transition = require("transition")
local widget = require("widget")
local sheet_helpers = require("globals.sheet_helpers")
local letter_grid_chooser = require("classes.letter_grid_chooser")

local M = {}
local meta = { __index = M }
local CENTER_X = 425

function M.new(onSelectLetter)
    local letterPicker = {
        onSelectLetter = onSelectLetter
    }

    return setmetatable(letterPicker, meta)
end

function M:render()
    self.view = display.newGroup()
    self.view.alpha = 0 --initially invisible.
    local screen = self:createScreen()
    local background = self:createBackground()
    local title = self:createTitle()
    self.letterGridChooser = letter_grid_chooser.new {
        x = display.contentCenterX + 55,
        y = display.contentCenterY - 75,
        padding = 10
    }
    local doneButton = self:createDoneButton()

    self.view:insert(screen)
    self.view:insert(background)
    self.view:insert(title)
    self.view:insert(self.letterGridChooser:render())
    self.view:insert(doneButton)

    return self.view
end

function M:show()
    if self.view then
        transition.fadeIn(self.view, {
            time = 1000
        })
    end
end

function M:createScreen()
    local screen = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    screen:setFillColor(0, 0, 0)
    screen.alpha = 0.5

    screen:addEventListener("touch", function(event)
        return true -- Don't allow touches propagating to underneath the menu
    end)
    screen:addEventListener("tap", function()
        return true
    end)
    return screen
end

function M:createBackground()
    local bookImg = display.newImageRect("images/book_popup.jpg", 750, 1024)
    bookImg.x, bookImg.y = display.contentCenterX, display.contentCenterY
    return bookImg
end

function M:createTitle()
    local title = display.newText {
        text = "Choose a letter",
        font = fonts.BOLD_FONT,
        fontSize = 60,
        x = CENTER_X,
        y = 250,
        align = "center",
        width = display.contentWidth
    }
    title:setFillColor(1, 1, 1)
    return title
end

function M:createDoneButton()
    local function onRelease()
        local currentLetter = self.letterGridChooser and self.letterGridChooser.selectedLetter
        if type(currentLetter) ~= "string" then
           currentLetter = "A"
        end

        self:close()
        if type(self.onSelectLetter) == "function" then
            if not self.didRunOnSelectLetter then
                self.didRunOnSelectLetter = true
                self.onSelectLetter(currentLetter)
            end
        end

    end

    local button = common_ui.createButton("Done", 1050, onRelease, nil, nil, nil)
    button.x = CENTER_X
    return button
end

function M:close()
    local view = self.view
    if view and view.removeSelf then


        local function onComplete()
            if view and view.removeSelf then
                view:removeSelf()
            end
        end

        transition.fadeOut(view, {
            time = 1000,
            onComplete = onComplete,
            onCancel = onComplete
        })
    end
end

function M:getArrayOfAllLetters()
    local allLetters = {}
    for i = 1, 26 do
        local letter = string.char(64 + i)
        allLetters[i] = letter
    end
    return allLetters
end


return M

