local M = {}

M.MIN_PASSWORD_LEN = 4
M.MAX_PASSWORD_LEN = 20

function M.validatePassword(pass1, pass2)
    if not pass1 or not type(pass1) == "string" or pass1:len() <= 0 then
        return false, "Please enter a password"
    elseif not pass2 or not type(pass2) == "string" or pass2:len() <= 0 then
        return false, "Please re-enter password"
    elseif pass1 ~= pass2 then
        return false, "The passwords don't match! Try again"
    elseif pass1:len() < M.MIN_PASSWORD_LEN then
        return false, "Password must be at least " .. tostring(M.MIN_PASSWORD_LEN) .. " characters long"
    elseif pass1:len() > M.MAX_PASSWORD_LEN then
        return false, "Password can't be longer than " .. tostring(M.MAX_PASSWORD_LEN) .. " characters long"
    end

    return true
end

return M
