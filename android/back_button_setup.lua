local system = require("system")
local composer = require("composer")
local native = require("native")
local tips_persist = require("tips.tips_persist")

local RETURN_TO_MAIN_MENU_TIP = "return_to_main_menu_tip"

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

    if currentScene.onBackButtonReturnToTitle == true then
        M.setBackListenerToReturnToTitleScene()
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

    M.setAndroidBackListener(backButton.onReleaseListener)
end

function M.setAndroidBackListener(onReleaseListener)

    if system.getInfo("platformName") ~= "Android" then
        return
    end

    if type(onReleaseListener) ~= "function" then
        M.setupDefaultBackListener()
        return
    end

    M.removeOldBackButtonListener()

    M.currentBackListener = function(event)
        if event.phase == "up" and event.keyName == "back" then
            onReleaseListener()
            return true
        end
        return false
    end

    Runtime:addEventListener("key", M.currentBackListener)
end

function M.setupDefaultBackListener()
    if system.getInfo("platformName") ~= "Android" then
        return
    end

    M.removeOldBackButtonListener()

    M.currentBackListener = function(event)
        if event.phase == "up" and event.keyName == "back" then
            return true
        end
        return false
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

function M.setBackListenerToExitApp()
    local function onReleaseListener()

        local function onClick(event)
            if event.action == "clicked" and event.index == 2 then
                native.requestExit()
            end
        end
        native.showAlert("Exit Ghostwriters", "Really exit?", {"Cancel", "OK"}, onClick)
    end

    M.setAndroidBackListener(onReleaseListener)
end

function M.setBackListenerToReturnToTitleScene()
    M.setAndroidBackListener(M.promptToReturnToMainMenu)
end

function M.promptToReturnToMainMenu()
    local function onClick(event)
        if event.action == "clicked" and event.index == 2 then
            composer.gotoScene("scenes.title_scene")
            tips_persist.recordViewedTip(RETURN_TO_MAIN_MENU_TIP)
        end
    end

    if tips_persist.isTipViewed(RETURN_TO_MAIN_MENU_TIP) then
        composer.gotoScene("scenes.title_scene", "fade")
    else
        native.showAlert("Return to Main Menu", "Exit game and return to Main Menu?", {"Cancel", "OK"}, onClick)
    end
end

return M

