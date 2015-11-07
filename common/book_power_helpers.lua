local M = {}

local COLOR_NO_BONUS = { 1, 1, 1 }
local COLOR_5_PERCENT = { 0.28, 1, 0.41 }
local COLOR_10_PERCENT = { 0.87, 0.73, 0.53 }
local COLOR_15_PERCENT = { 0.29, 0.92, 0.92 }
local COLOR_20_PERCENT = { 1, 0.65, 0.2 }
local COLOR_25_PERCENT = {225 / 255, 0, 255 / 255}  -- light purple

local COLOR_NO_BONUS_DARK = { 0.1, 0.1, 0.1 }
local COLOR_5_PERCENT_DARK = { 0.06, 0.54, 0.13 }
local COLOR_10_PERCENT_DARK = { 0.37, 0.23, 0 }
local COLOR_15_PERCENT_DARK = { 0.06, 0.23, 0.77 }
local COLOR_20_PERCENT_DARK = { 0.66, 0.23, 0 }
local COLOR_25_PERCENT_DARK = {133 / 255, 16, 148 / 255} -- dark purple

function M.getBookPowerBonusFromUser(userModel)
    if not userModel then
        return 0
    end

    return M.getBookPowerBonusFromTokens(userModel.tokens, userModel.infiniteBooks)
end

function M.getBookPowerBonusFromTokens(numTokens, infiniteBooks)
    if infiniteBooks then
        return 25
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
        return isLightColor and COLOR_25_PERCENT or COLOR_25_PERCENT_DARK
    end

    if type(numTokens) ~= "number" then
        return isLightColor and COLOR_NO_BONUS or COLOR_NO_BONUS_DARK
    end

    if numTokens >= 500 then
        return isLightColor and COLOR_20_PERCENT or COLOR_20_PERCENT_DARK
    elseif numTokens >= 250 then
        return isLightColor and COLOR_15_PERCENT or COLOR_15_PERCENT_DARK
    elseif numTokens >= 100 then
        return isLightColor and COLOR_10_PERCENT or COLOR_10_PERCENT_DARK
    elseif numTokens >= 10 then
        return isLightColor and COLOR_5_PERCENT or COLOR_5_PERCENT_DARK
    end

    return isLightColor and COLOR_NO_BONUS or COLOR_NO_BONUS_DARK
end

return M

