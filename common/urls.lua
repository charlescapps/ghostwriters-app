local M = {}

local SERVER = "https://ghostwriters.herokuapp.com/api"
--local SERVER = "http://localhost:8080/api"

M.escape = function(str)
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^0-9a-zA-Z ])", -- locale independent
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
    return str
end

-- Functions to construct URLs
-- May be a constant URL, or may require query params
M.loginURL = function()
    return SERVER .. "/login"
end

M.usersURL = function()
    return SERVER .. "/users"
end

M.getSelfURL = function()
    return SERVER .. "/users/me"
end

M.nextUsernameURL = function(deviceId)
    local url =  M.usersURL() .. "/nextUsername"
    if deviceId then
        return url .. "?deviceId=" .. M.escape(deviceId)
    else
        return url
    end
end

M.gamesURL = function()
    return SERVER .. "/games"
end

M.gameByIdURL = function(gameId, includeMoves, currentMove)
    local includeMovesParam
    if includeMoves then
        includeMovesParam = "true"
    else
        includeMovesParam = "false"
    end

    local url = SERVER .. "/games/" .. tostring(gameId) .. "?includeMoves=" .. includeMovesParam

    if currentMove then
        url = url .. "&currentMove=" .. tostring(currentMove)
    end

    return url
end

M.myGamesURL = function(count, inProgress, includeMoves)
    local baseURL = M.gamesURL()
    local url = baseURL .. "?count=" .. count .. "&inProgress=" .. tostring(inProgress)
    if includeMoves then
        url = url .. "&includeMoves=true"
    end
    return url
end

M.myGamesSummaryURL = function()
    return SERVER .. "/users/myGamesSummary"
end

M.gamesOfferedToMeURL = function(count)
    return SERVER .. "/games/offeredToMe?count=" .. tostring(count)
end

M.gamesOfferedByMeURL = function(count)
    return SERVER .. "/games/offeredByMe?count=" .. tostring(count)
end

M.movesURL = function()
    return SERVER .. "/moves"
end

M.getBestMatchURL = function()
    return SERVER .. "/users/bestMatch"
end

M.getUsersWithSimilarRatingURL = function(maxResults)
    return SERVER .. "/users/similarRating?maxResults=" .. tostring(maxResults)
end

M.getAcceptGameURL = function(gameId)
    return SERVER .. "/games/" .. tostring(gameId) .. "/accept"
end

M.getRejectGameURL = function(gameId)
    return SERVER .. "/games/" .. tostring(gameId) .. "/reject"
end

M.getRanksAroundUserURL = function(userId, maxResults)
    return SERVER .. "/users/" .. tostring(userId) .. "/similarRank?maxResults=" .. tostring(maxResults)
end

M.getBestRankedUsersURL = function(maxResults)
    return SERVER .. "/users/bestRanked?maxResults=" .. tostring(maxResults)
end

M.getRanksNearProfessorURL = function(maxResults)
    return SERVER .. "/users/professorRank?maxResults=" .. tostring(maxResults)
end

M.getRanksNearBookwormURL = function(maxResults)
    return SERVER .. "/users/bookwormRank?maxResults=" .. tostring(maxResults)
end

M.getRanksNearMonkeyURL = function(maxResults)
    return SERVER .. "/users/monkeyRank?maxResults=" .. tostring(maxResults)
end

M.getPurchaseURL = function()
    return SERVER .. "/tokens/purchase"
end

return M

