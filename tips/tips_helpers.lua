local display = require("display")
local widget = require("widget")
local tips_modal = require("tips.tips_modal")

local M = {}

function M.drawTipButton(tipText, width, height, parentScene)
    local function onRelease()
        local tipsModal = tips_modal.new(tipText)
        tipsModal:show()
    end

    return widget.newButton {
        width = width or 100,
        height = height or 100,
        defaultFile = "images/question_button_default.png",
        overFile = "images/question_button_over.png",
        onRelease = onRelease
    }
end

return M

