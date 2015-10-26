local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "choose_bonus_tiles_tip"

function M.new(disableRecordTip, onReleaseButton)
    local chooseGameSizeTip = {
        disableRecordTip = disableRecordTip,
        onReleaseButton = onReleaseButton
    }
    return setmetatable(chooseGameSizeTip, meta)
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
    end
    self.tipsModal = tips_modal.new(
        "Tap the + buttons to start the game with bonus tiles.",
        nil,
        onClose,
        "images/choose_bonus_tiles.jpg", 400, 247, 0, -20, self.onReleaseButton)
    return self.tipsModal:show()
end

return M
