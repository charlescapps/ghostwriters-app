local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "play_word_alone_tip"

function M.new(disableRecordTip, onCloseTip)
    local currencyTip = {
        disableRecordTip = disableRecordTip,
        onCloseTip = onCloseTip
    }
    return setmetatable(currencyTip, meta)
end

function M:triggerTipOnCondition()
   -- Trivial condition, always true
    return self:showTip()
end

function M:showTip()
    if not tips_persist.isTipViewed(TIP_NAME) then
        self:renderTip()
        return true
    end

    return false
end

function M:renderTip()
    local function onClose()
        if not self.disableRecordTip then
            tips_persist.recordViewedTip(TIP_NAME)
        end
        if type(self.onCloseTip) == "function" then
            self.onCloseTip()
        end
    end
    self.tipsModal = tips_modal.new(
        "You can play words anywhere, even if they aren't touching other letters!",
        nil, onClose, "images/play_word_alone_tip.jpg", 300, 218, 0, 0)
    return self.tipsModal:show()
end

return M
