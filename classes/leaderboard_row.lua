local display = require("display")

local leaderboard_row = {}
local leaderboard_row_mt = { __index = leaderboard_row }

function leaderboard_row.new(user)
    local leaderboardRow = {
        user = user
    }

    return setmetatable(leaderboardRow, leaderboard_row_mt)
end

function leaderboard_row:render()
    self.view = display.newGroup()
end


return leaderboard_row

