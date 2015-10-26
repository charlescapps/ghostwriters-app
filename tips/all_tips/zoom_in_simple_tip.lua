local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "zoom_in_tip"

function M.new(disableRecordTip, onReleaseButton)
    local zoomInTip = {
        disableRecordTip = disableRecordTip,
        onReleaseButton = onReleaseButton
    }
    return setmetatable(zoomInTip, meta)
end

function M:renderTip()
        local function onClose()
            if not self.disableRecordTip then
                tips_persist.recordViewedTip(TIP_NAME)
            end
        end
        self.tipsModal = tips_modal.new(
            "Double-tap the board to zoom in!\n\n" ..
            "Double-tap again to zoom back out.",
            nil, onClose, nil, nil, nil, nil, nil, self.onReleaseButton)
        return self.tipsModal:show()
end


return M
