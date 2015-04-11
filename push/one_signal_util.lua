local GameThrive = require("plugin.GameThrivePushNotifications")
local composer = require("composer")
local json = require("json")
local current_game = require("globals.current_game")

local M = {}

M.ONE_SIGNAL_APP_ID = "479f3518-dbfa-11e4-ac8e-a310507ee73c"
M.ANDROID_PROJECT_NUM = "9329334853"

function M.initOneSignal()
    GameThrive.DisableAutoRegister()
    GameThrive.Init(M.ONE_SIGNAL_APP_ID, M.ANDROID_PROJECT_NUM, M.onReceiveNotification)
end

function M.onReceiveNotification(message, additionalData, isActive)
    local additionalDataStr = json.encode(additionalData)
    print("Received notification:message=" .. message)
    print("additionalData=" .. additionalDataStr)
    if not additionalData or not additionalData.updatedGame then
        print("Received push notification without updatedGame field: " .. additionalDataStr)
        return
    end

    local updatedGame = additionalData.updatedGame
    local currentSceneName = composer.getSceneName("current")
    local currentGame = current_game.currentGame

    -- If the current scene is the play_game_scene, then just update the game in view
    if currentSceneName == "scenes.play_game_scene" then
       local playGameScene = composer.getScene("scenes.play_game_scene")
        if playGameScene and playGameScene:isValidGameScene() then
            print("currentGame.id='" .. tostring(currentGame.id) .. "'")
            print("updatedGame='" .. updatedGame .. "'")
            if currentGame and tostring(currentGame.id) == updatedGame then
                print("Current scene is play_game_scene, and it's valid, so updating existing game.")
                playGameScene:refreshGameFromServer()
                return
            else
                print("Current game doesn't match game id. Current = '" .. tostring(currentGame.id) .. "', from push = '" .. updatedGame .. "'")
            end
        end
    else
        print("Current scene is not play_game_scene, so not updating game:" .. currentSceneName)
    end
end


return M

