local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "scry_tile_tip"

function M.new(disableRecordTip, onCloseTip)
    local scryTileTip = {
        disableRecordTip = disableRecordTip,
        onCloseTip = onCloseTip
    }
    return setmetatable(scryTileTip, meta)
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
    self.tipsModal = tips_modal.new("Drag Oracle tiles from your hand to the board to reveal a powerful word.",
         nil, onClose,
        "images/scry_tip.png", 250, 250, 0, 0)
    return self.tipsModal:show()
end

return M
