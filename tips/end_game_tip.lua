local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "end_game_tip"

function M.new(disableRecordTip, onCloseTip)
    local endGameTip = {
        disableRecordTip = disableRecordTip,
        onCloseTip = onCloseTip
    }
    return setmetatable(endGameTip, meta)
end

function M:triggerTipOnCondition()
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
        "A game ends when all tiles on the board are stone, and " ..
                "the turn passes to a player who's out of tiles.\n\n" ..
                "The player with the most points wins!",
        nil, onClose)
    return self.tipsModal:show()
end


return M
