local display = require("display")
local transition = require("transition")
local easing = require("easing")
local fonts = require("globals.fonts")

local slidey_bookmark = {}
local slidey_bookmark_mt = { __index = slidey_bookmark }

local BOOKMARK_WIDTH = 200
local BOOKMARK_HEIGHT = 150
local IMGS = { "images/bookmark1_small.png", "images/bookmark2_small.png" }

function slidey_bookmark.new(num, imgIndex, yPos)
    local slideyBookmark = {
        num = num,
        imgIndex = imgIndex,
        yPos = yPos
    }

    return setmetatable(slideyBookmark, slidey_bookmark_mt)
end

function slidey_bookmark:render()
    self.view = display.newGroup()
    self.view.y = self.yPos
    self.view.x = -BOOKMARK_WIDTH / 2 -- initially off the screen

    self.bookmark = self:drawBookmark()
    self.numberBubble = self:drawNumberBubble()

    self.view:insert(self.bookmark)
    self.view:insert(self.numberBubble)
    return self.view
end

function slidey_bookmark:slideIn()
    transition.to(self.view, {
        time = 1000,
        x = BOOKMARK_WIDTH / 4,
        transition = easing.outBack
    })
end

function slidey_bookmark:drawNumberBubble()
    return display.newText {
        text = tostring(self.num),
        x = 20,
        y = 0,
        font = fonts.BOLD_FONT,
        fontSize = 40
    }
end

function slidey_bookmark:drawBookmark()
    return display.newImageRect(IMGS[self.imgIndex], BOOKMARK_WIDTH, BOOKMARK_HEIGHT)
end

return slidey_bookmark

