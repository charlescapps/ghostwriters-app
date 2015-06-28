local M = {}

function M.comma_value(amount)
    if amount == nil then
        return "n/a"
    end
    local formatted = amount
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end

return M

