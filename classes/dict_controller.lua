local M = {}
local meta = { __index = M }

function M.new(scene, specialDict)
    local dictController = {
        scene = scene,
        specialDict = specialDict,
        currentPage = 1
    }
    return setmetatable(dictController, meta)
end

function M:render()

end

function M:setDictionary(dict)
    self.dict = dict

end

function M:nextPage()

end

function M:prevPage()

end


return M

