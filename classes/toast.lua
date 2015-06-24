local display = require("display")
local transition = require("transition")
local easing = require("easing")
local timer = require("timer")
local fonts = require("globals.fonts")

local M = {}
local meta = { __index = M }

local BOOKMARK_WIDTH = 800
local BOOKMARK_HEIGHT = 150
local AUTO_DESTROY_DELAY = 10000

function M.new(text, fontSize, onTouch)
    local myToast = {
        text = text,
        fontSize = fontSize or 32,
        onTouch = onTouch
    }

    myToast = setmetatable(myToast, meta)
    print("Rendering toast...")
    myToast:render()
    return myToast
end

function M:render()
    self.view = display.newGroup()
    self.view.x = -BOOKMARK_WIDTH / 2
    self.view.y = 100

    print("Drawing toast.bookmark...")
    self.bookmark = self:drawBookmark()
    self.view:insert(self.bookmark)

    print("Drawing toast.bookmarkText...")
    self.bookmarkText = self:drawBookmarkText()
    self.view:insert(self.bookmarkText)

    self:addTouchListener()

    self:show()
    timer.performWithDelay(AUTO_DESTROY_DELAY, function() self:hideAndDestroy() end)
end

function M:drawBookmark()
    self.bookmark = display.newImageRect("images/bookmark_toast.png", BOOKMARK_WIDTH, BOOKMARK_HEIGHT)
    return self.bookmark
end

function M:drawBookmarkText()
    local bookmarkText = display.newText {
        text = self.text,
        x = -30,
        y = 32,
        font = fonts.BOLD_FONT,
        fontSize = self.fontSize,
        align = "center",
        width = BOOKMARK_WIDTH,
        height = BOOKMARK_HEIGHT
    }
    return bookmarkText
end

function M:addTouchListener()
    local toast = self
    self.bookmark:addEventListener("touch", function(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            if toast.onTouch then
                toast.onTouch()
            end
            toast:hideAndDestroy()
        elseif event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end)

    self.bookmark:addEventListener("tap", function(event)
        return true
    end)
end

function M:show()
    transition.to(self.view, { x = BOOKMARK_WIDTH / 2 - 10, time = 1600, transition = easing.inOutQuart })
end

function M:hideAndDestroy()
    if not self.view or not self.view.removeSelf then
        return
    end
    local function onComplete()
        self:destroy()
    end
    transition.to(self.view, { x = -BOOKMARK_WIDTH / 2, time = 1000, transition = easing.outBack,
        onComplete = onComplete, onCancel = onComplete})
end

function M:destroy()
    if self.view and self.view.removeSelf then
        self.view:removeSelf()
    end
end

return M

