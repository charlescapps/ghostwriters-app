local slidey_bookmark = {}
local slidey_bookmark_mt = { __index = slidey_bookmark }

function slidey_bookmark.new(parentScene, num, style)
    local slideyBookmark = {
        parentScene = parentScene,
        num = num,
        style = style
    }
end

return slidey_bookmark

