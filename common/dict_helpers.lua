local common_api = require("common.common_api")

local M = {}

M.HEAD_WIDTH = 300
M.HEAD_HEIGHT = 350

function M.getDictImageFile(SPECIAL_DICT)
    if not SPECIAL_DICT then
        return nil
    elseif SPECIAL_DICT == common_api.DICT_POE then
        return "images/head_poe.png"
    elseif SPECIAL_DICT == common_api.DICT_LOVECRAFT then
        return "images/head_lovecraft.png"
    elseif SPECIAL_DICT == common_api.DICT_MYTHOS then
        return "images/head_cthulhu.png"
    end
end


return M

