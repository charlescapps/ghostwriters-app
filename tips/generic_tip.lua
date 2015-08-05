local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")

local M = {}
local meta = { __index = M }

function M.new(tipName, tipText)
    local genericTip = {
        tipName = tipName,
        tipText = tipText
    }
    return setmetatable(genericTip, meta)
end

function M:triggerTipOnCondition()
   -- Trivial condition, always true
    self:showTip()
end

function M:showTip()
    if  type(self.tipName) ~= "string" then
        print("ERROR - must provide a 'tipName' for a generic_tip")
        return
    end

    if type(self.tipText) ~= "string" and self.tipText:len() > 0 then
        print("ERROR - must provide a 'tipText' that is non-empty for a generic_tip")
        return
    end

    if not tips_persist.isTipViewed(self.tipName) then
        local function onClose()
            tips_persist.recordViewedTip(self.tipName)
        end
        local tipsModal = tips_modal.new(
            self.tipText,
            nil, onClose)
        tipsModal:show()
    end

end


return M
