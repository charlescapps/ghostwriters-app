local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

local TIP_NAME = "question_tile_tip"

function M.new(disableRecordTip, onCloseTip)
    local questionTileTip = {
        disableRecordTip = disableRecordTip,
        onCloseTip = onCloseTip
    }
    return setmetatable(questionTileTip, meta)
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
        "Drag a question tile to the board, then choose a letter. The chosen letter is worth full points!",
        nil, onClose,
        "images/question_tip.png", 250, 250, 0, 0)
    return self.tipsModal:show()
end




return M
