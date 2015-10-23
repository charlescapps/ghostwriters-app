local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "pass_tip"

function M.new()
    local endGameTip = {
    }
    return setmetatable(endGameTip, meta)
end

function M:triggerTipOnCondition()
    return self:showTip()
end

function M:showTip()
    if not tips_persist.isTipViewed(TIP_NAME) then
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        local tipsModal = tips_modal.new(
            "You can pass by tapping the hourglass if you can't find a good move.",
            nil, onClose, "images/pass_button_default.png", 160, 160)
        tipsModal:show()
        return true
    end

    return false
end


return M
