local display = require("display")
local transition = require("transition")
local format_helpers = require("common.format_helpers")
local fonts = require("globals.fonts")
local json = require("json")

local M = {}
local __meta = { __index = M }

-- CONSTANTS
local CORNER_RADIUS = 20
local RIGHT_PAD = 10
local MID_PAD = 5

function M.new(opts)
    opts = opts or {}

    local caChing = {
        x = opts.x or 0,
        y = opts.y or 0,
        font = opts.font or fonts.BOLD_FONT,
        fontSize = opts.fontSize or 28,
        width = opts.width or 200,
        height = opts.height or 45,
        points = opts.points or 0
    }

    print ("Creating ca-ching with initial values = " .. json.encode(caChing))

    return setmetatable(caChing, __meta)

end

function M:render()

    -- A container so that points drawn outside these bounds are invisible.
    self.view = display.newContainer(self.width, self.height)
    self.view.x, self.view.y = self.x, self.y

    -- Rounded rect border
    self.view:insert(self:drawRoundedRect())

    -- The text "points"
    self.pointsText = self:drawPointsText()
    self.view:insert(self.pointsText)

    return self.view
end

function M:drawRoundedRect()
    local rect = display.newRoundedRect(0, 0, self.width, self.height, CORNER_RADIUS)
    rect.strokeWidth = 3
    rect:setStrokeColor(0, 0, 0)
    rect:setFillColor(1, 1, 1, 0.8)
    return rect
end

function M:drawPointsText()
    local pointsText = display.newText {
        text = format_helpers.comma_value(self.points) .. " points",
        x = self.width / 2,
        y = 0,
        font = self.font,
        fontSize = self.fontSize,
        width = self.width,
        align = "center"
    }
    pointsText.anchorX = 1
    pointsText:setFillColor(0, 0, 0)
    return pointsText
end

function M:setPoints(newPoints)
    print("Setting points to: " .. tostring(newPoints))
    
end

return M

