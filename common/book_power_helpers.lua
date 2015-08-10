local M = {}

local COLOR_NO_BONUS = { 1, 1, 1 }
local COLOR_5_PERCENT = { 0.28, 1, 0.41 }
local COLOR_10_PERCENT = { 0.87, 0.73, 0.53 }
local COLOR_15_PERCENT = { 0.29, 0.92, 0.92 }
local COLOR_20_PERCENT = { 1, 0.65, 0.2 }

function M.getBookPowerBonusFromUser(userModel)
    if not userModel then
        return 0
    end

    return M.getBookPowerBonusFromTokens(userModel.tokens, userModel.infiniteBooks)
end

function M.getBookPowerBonusFromTokens(numTokens, infiniteBooks)
    if infiniteBooks then
        return 20
    end

    if type(numTokens) ~= "number" then
        return 0
    end

    if numTokens >= 500 then
        return 20
    elseif numTokens >= 250 then
        return 15
    elseif numTokens >= 100 then
        return 10
    elseif numTokens >= 10 then
        return 5
    end

    return 0
end

function M.getBookPowerColor(isLightColor, numTokens, infiniteBooks)
    if infiniteBooks then
        return COLOR_20_PERCENT
    end

    if type(numTokens) ~= "number" then
        return COLOR_NO_BONUS
    end

    if numTokens >= 500 then
        return COLOR_20_PERCENT
    elseif numTokens >= 250 then
        return COLOR_15_PERCENT
    elseif numTokens >= 100 then
        return COLOR_10_PERCENT
    elseif numTokens >= 10 then
        return COLOR_5_PERCENT
    end

    return COLOR_NO_BONUS
end

return M

