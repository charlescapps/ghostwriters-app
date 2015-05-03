local current_game = require("globals.current_game")
local imgs = require("globals.imgs")
local display = require("display")
local transition = require("transition")

local game_options_modal = {}
local game_options_modal_mt = { __index = game_options_modal }

function game_options_modal.new(parentScene)
    local gameOptionsModal = {
        parentScene = parentScene
    }
    return setmetatable(gameOptionsModal, game_options_modal_mt)
end

function game_options_modal:render()
    self.view = display.newGroup()
    self.view.alpha = 0

    self.bg = self:drawBlackBackground()
    self.oldBook = self:drawOldBook()

    self.view:insert(self.bg)
    self.view:insert(self.oldBook)
    return self.view
end

function game_options_modal:show()
    transition.fadeIn(self.view, {
        time = 800
    })
end

function game_options_modal:hide()
    transition.fadeOut(self.view, {
        time = 800
    })
end

function game_options_modal:drawBlackBackground()
    local bg = display.newRect(self.parentScene.view, display.contentWidth / 2, display.contentHeight / 2,
        display.contentWidth, display.contentHeight)
    bg:setFillColor(0, 0, 0, 0.5)
    local that = self
    function bg:touch(event)
        if event.phase == "began" then
           display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            that:hide()
        elseif event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end
    bg:addEventListener("touch")
    return bg
end

function game_options_modal:drawOldBook()
    local book = display.newImageRect(imgs.OLD_BOOK, imgs.OLD_BOOK_WIDTH, imgs.OLD_BOOK_HEIGHT)
    book.x = display.contentWidth / 2
    book.y = display.contentHeight / 2
    function book:touch(event)
        return true
    end
    book:addEventListener("touch")
    return book
end

return game_options_modal

