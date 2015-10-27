local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "ranking_tip"

function M.new(disableRecordTip, onCloseTip)
    local rankingTip = {
        disableRecordTip = disableRecordTip,
        onCloseTip = onCloseTip
    }
    return setmetatable(rankingTip, meta)
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
        "Battle your way up the leaderboard by playing games!\n\n" ..
                "Earn more points by defeating opponents with a higher rating.",
        nil, onClose)
    return self.tipsModal:show()
end


return M
