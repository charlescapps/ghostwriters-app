local display = require("display")
local widget = require("widget")
local graphics = require("graphics")
local ghostly_tall = require("spritesheets.ghostly_tall")

local word_spinner_class = {}
local word_spinner_class_mt = { __index = word_spinner_class }

-- Constants
local IMAGE_SHEET = "spritesheets/ghostly_tall.png"
local WIDTH = 300

function word_spinner_class.new(x, y)

    local options = ghostly_tall:getSheet()

    local spinnerSingleSheet = graphics.newImageSheet( IMAGE_SHEET, options )

    -- Create the widget
    local spinner = widget.newSpinner
        {
            x = x or display.contentCenterX,
            y = y or display.contentCenterY,
            width = WIDTH,
            height = WIDTH,
            sheet = spinnerSingleSheet,
            startFrame = ghostly_tall:getFrameIndex("g_ghostly"),
            count = 1,
            deltaAngle = 10,
            incrementEvery = 40
        }

    local wordSpinner = {
        spinner = spinner
    }

    return setmetatable(wordSpinner, word_spinner_class_mt)
end

function word_spinner_class:start()
    self.screen = self:createScreen()
    self.screen:toFront()
    self.spinner:toFront()
    self.spinner:start()
end

function word_spinner_class:stop()
    print("Stopping word spinner...")
    self.isStopped = true
    if self.spinner and self.spinner.removeSelf then
        self.spinner:removeSelf()
        self.spinner = nil
    end
    if self.screen and self.screen.removeSelf then
        self.screen:removeSelf()
        self.screen = nil
    end
end

function word_spinner_class:createScreen()
    local x, y = display.contentCenterX, display.contentCenterY
    local screen = display.newRect(x, y, display.contentWidth, display.contentHeight)
    screen:setFillColor(0, 0, 0)
    screen.alpha = 0.3

    screen:addEventListener("touch", function(event)
        return true
    end)

    screen:addEventListener("tap", function(event)
        return true
    end)

    return screen
end


return word_spinner_class

