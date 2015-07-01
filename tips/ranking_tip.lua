local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "ranking_tip"

function M.new()
    local rankingTip = {
    }
    return setmetatable(rankingTip, meta)
end

function M:triggerTipOnCondition()
   -- Trivial condition, always true
    self:showTip()
end

function M:showTip()
    if not tips_persist.isTipViewed(TIP_NAME) then
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        local tipsModal = tips_modal.new(
            "Battle your way up the leaderboard by playing games!\n\n" ..
            "Earn more points by defeating opponents with a higher rating.",
            nil, onClose)
        tipsModal:show()
    end

end


return M
