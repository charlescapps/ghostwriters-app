local display = require("display")
local transition = require("transition")
local format_helpers = require("common.format_helpers")
local fonts = require("globals.fonts")
local json = require("json")
local common_ui = require("common.common_ui")
local easing = require("easing")

local M = {}
local __meta = { __index = M }

-- CONSTANTS
local CORNER_RADIUS = 20
local RIGHT_PAD = 10
local MID_PAD = 5
local OFF_VISIBLE_AREA_PAD = 50
local TIME_TO_MOVE = 2000

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

    --print ("Creating ca-ching with initial values = " .. json.encode(caChing))

    return setmetatable(caChing, __meta)

end

function M:render()

    -- A container so that points drawn outside these bounds are invisible.
    self.view = display.newContainer(self.width + 5, self.height + 5)
    self.view.x, self.view.y = self.x, self.y

    -- Rounded rect border
    self.view:insert(self:drawRoundedRect())

    -- The text "points"
    self.pointsText = self:drawPointsText(self.points)
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

function M:drawPointsText(numPoints)
    local pointsText = display.newText {
        text = format_helpers.comma_value(numPoints) .. " points",
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

function M:addPoints(numPoints)
    local currentPoints = self.points
    if type(currentPoints) ~= "number" then
        return
    end

    local newPoints = numPoints + currentPoints
    self:setPoints(newPoints)
end

function M:setPoints(newPoints)
    local container = self.view

    if not common_ui.isValidDisplayObj(container) then
        return
    end

    print("Setting points to: " .. tostring(newPoints))
    local newPointsText = self:drawPointsText(newPoints)
    newPointsText.y = self.height / 2 + newPointsText.height / 2 + OFF_VISIBLE_AREA_PAD
    container:insert(newPointsText)

    local function onCompleteMoveOldPoints(obj)
        common_ui.safeRemove(obj)
    end

    local oldPointsText = self.pointsText
    if common_ui.isValidDisplayObj(oldPointsText) then
        transition.to(oldPointsText, {
            onComplete = onCompleteMoveOldPoints,
            onCancel = onCompleteMoveOldPoints,
            y = -self.height / 2 - oldPointsText.height / 2 - OFF_VISIBLE_AREA_PAD,
            time = TIME_TO_MOVE,
            transition = easing.outBack
        })
    end

    local function onCompleteMoveNewPoints(obj)
        if not common_ui.isValidDisplayObj(obj) then
            return
        end
        self.pointsText = obj
        obj.y = 0
        self.points = newPoints
    end

    transition.to(newPointsText, {
        onComplete = onCompleteMoveNewPoints,
        onCancel = onCompleteMoveNewPoints,
        y = 0,
        time = TIME_TO_MOVE,
        transition = easing.outBack
    })
end

return M

