local math = require("math")
local os = require("os")

local M = {}

local SECS_PER_YEAR = 60 * 60 * 24 * 365
local SECS_PER_DAY = 60 * 60 * 24
local SECS_PER_HOUR = 60 * 60
local SECS_PER_MINUTE = 60

function M.printDurationPrettyFromStartTime(timestampSecs)
    local now = os.time()
    local diff = now - timestampSecs
    if diff < 0 then
        print("ERROR - timestamp is from the past. Timestamp = " .. timestampSecs .. ", but now = " .. now)
        print("ERROR - timestamp is from the past. Returning 0 for the duration")
        diff = 0
    end
    return M.printDurationPretty(diff)
end

function M.printDurationPretty(secs)
    local years, days, hours, minutes = math.floor(secs / SECS_PER_YEAR),
                                        math.floor(secs / SECS_PER_DAY),
                                        math.floor(secs / SECS_PER_HOUR),
                                        math.floor(secs / SECS_PER_MINUTE)
    if years > 0 then
        return "more than a year ago"
    end

    if days == 1 then
        return "yesterday"
    elseif days > 1 then
        return days .. " days ago"
    end

    if hours == 1 then
        return "an hour ago"
    elseif hours > 1 then
        return hours .. " hours ago"
    end

    if minutes == 1 then
        return "about a minute ago"
    elseif minutes > 1 then
        return minutes .. " minutes ago"
    end

    return "less than a minute ago"
end

return M

