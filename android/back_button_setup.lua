local system = require("system")
local json = require("json")

local M = {}

M.currentBackListener = nil

function M.setupBackButtonListener(backButton, onRelease)

    if system.getInfo("platformName") ~= "Android" then
        return
    end

    if not M.isBackButtonValid(backButton) then
        M.setupDefaultBackListener()
        return
    end

    M.removeOldBackButtonListener()

    M.currentBackListener = function(event)
        print("Key event: " .. json.encode(event))
        if event.phase == "up" and event.keyName == "back" then
            print("SUCCESS - Key event for phase == 'up' and keyName == 'back'!")
            if M.isBackButtonValid(backButton) and onRelease then
                onRelease()
            end
        end
        return true
    end

    Runtime:addEventListener("key", M.currentBackListener)
end

function M.setupDefaultBackListener()
    M.removeOldBackButtonListener()

    M.currentBackListener = function(event)
        return true
    end

    Runtime:addEventListener("key", M.currentBackListener)
end

function M.isBackButtonValid(backButton)
    return backButton and backButton.parent and backButton.removeSelf and true
end


function M.removeOldBackButtonListener()
    if M.currentBackListener then
        Runtime:removeEventListener("key", M.currentBackListener)
        M.currentBackListener = nil
    end
end

return M

