local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")
local tips_helpers = require("tips.tips_helpers")

local M = {}
local meta = { __index = M }

local TIP_NAME = "play_word_tip"

function M.new(disableRecordTip, onReleaseButton)
    local playWordTip = {
        disableRecordTip = disableRecordTip,
        onReleaseButton = onReleaseButton
    }
    return setmetatable(playWordTip, meta)
end

function M:renderTip()
        local function onClose()
            if not self.disableRecordTip then
                tips_persist.recordViewedTip(TIP_NAME)
            end
        end
        self.tipsModal = tips_modal.new(
            "To play a word, drag tiles from your hand to the board.\n\n" ..
            "Then press the Play button, and earn points!",
            nil, onClose, nil, nil, nil, nil, nil, self.onReleaseButton)
        return self.tipsModal:show()

end


return M
