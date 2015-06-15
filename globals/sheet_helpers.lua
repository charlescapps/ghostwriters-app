local graphics = require("graphics")

local M = {}
M.spritesheets = {}

function M:getSheetObj(spritesheetName)
    if self.spritesheets[spritesheetName] then
        return self.spritesheets[spritesheetName]
    end

    local module = require("spritesheets." .. spritesheetName)
    local imageSheet = graphics.newImageSheet("spritesheets/" .. spritesheetName .. ".png", module:getSheet())

    self.spritesheets[spritesheetName] = {
        module = module,
        imageSheet = imageSheet
    }

    return self.spritesheets[spritesheetName]

end


return M

