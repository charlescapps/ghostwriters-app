
local leaderboard_class = {}
local leaderboard_class_mt = { __index = leaderboard_class }

function leaderboard_class.new()
    local leaderBoard = {
    }
    return setmetatable(leaderBoard, leaderboard_class_mt)
end

function leaderboard_class:render()

end


return leaderboard_class

