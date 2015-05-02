local display = require("display")

local slidey_bookmark = {}
local slidey_bookmark_mt = { __index = slidey_bookmark }

function slidey_bookmark.new(parentScene, num, style, yPos)
    local slideyBookmark = {
        parentScene = parentScene,
        num = num,
        style = style,
        yPos = yPos
    }
end

function slidey_bookmark:render()
    self.view = display.newGroup()


end

return slidey_bookmark

