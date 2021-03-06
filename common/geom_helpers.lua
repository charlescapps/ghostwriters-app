local common_ui = require("common.common_ui")

local M = {}

function M.intersects(obj1, obj2)
    if not common_ui.isValidDisplayObj(obj1) or not common_ui.isValidDisplayObj(obj2) then
        return false
    end

    local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
    local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
    local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
    local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax

    return (left or right) and (up or down)
end

function M.contains(container, obj, pad)
    if not common_ui.isValidDisplayObj(container) or not common_ui.isValidDisplayObj(obj) then
        return false
    end

    pad = pad or 0

    local cBounds = container.contentBounds
    local oBounds = obj.contentBounds

    return oBounds.xMin >= cBounds.xMin - pad and
           oBounds.xMax <= cBounds.xMax + pad and
           oBounds.yMin >= cBounds.yMin - pad and
           oBounds.yMax <= cBounds.yMax + pad
end

return M
