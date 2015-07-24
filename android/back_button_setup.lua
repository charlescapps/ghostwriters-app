local system = require("system")
local json = require("json")
local composer = require("composer")

local M = {}

M.currentBackListener = nil

function M.restoreBackButtonListenerCurrentScene()
    local currentSceneName = composer.getSceneName("current")
    if not currentSceneName then
        return
    end

    local currentScene = composer.getScene(currentSceneName)

    if not currentScene then
        return
    end

    M.setupBackButtonListener(currentScene.backButton)
end

function M.setupBackButtonListener(backButton)

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
            if M.isBackButtonValid(backButton) then
                backButton.onReleaseListener()
            end
        end
        return true
    end

    Runtime:addEventListener("key", M.currentBackListener)
end

function M.setupDefaultBackListener()
    if system.getInfo("platformName") ~= "Android" then
        return
    end

    M.removeOldBackButtonListener()

    M.currentBackListener = function(event)
        return true
    end

    Runtime:addEventListener("key", M.currentBackListener)
end

function M.isBackButtonValid(backButton)
    return backButton and backButton.parent and backButton.removeSelf and backButton.onReleaseListener and true
end


function M.removeOldBackButtonListener()
    if M.currentBackListener then
        Runtime:removeEventListener("key", M.currentBackListener)
        M.currentBackListener = nil
    end
end

return M

