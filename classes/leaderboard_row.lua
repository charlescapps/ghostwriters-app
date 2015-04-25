local display = require("display")

local leaderboard_row = {}
local leaderboard_row_mt = { __index = leaderboard_row }

function leaderboard_row.new(index, user)
    local leaderboardRow = {
        index = index,
        user = user
    }

    return setmetatable(leaderboardRow, leaderboard_row_mt)
end

function leaderboard_row:render()
    self.view = display.newGroup()
    self.bookmarkBg = self:createBookmarkBg()

    self.view:insert(self.bookmarkBg)
    return self.view
end

function leaderboard_row:createBookmarkBg()
    local imgFile = self.index % 2 == 0 and "images/blue_bookmark.png" or "images/red_bookmark.png"
    return display.newImageRect(imgFile, 550, 120)
end

return leaderboard_row

