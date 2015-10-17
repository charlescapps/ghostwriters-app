local transition = require("transition")

local M = {}

function M.pauseAll()
    transition.pause()
end

function M.resumeAll()
    transition.resume()
end

return M

