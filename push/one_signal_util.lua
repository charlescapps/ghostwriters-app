local GameThrive = require("plugin.GameThrivePushNotifications")
local composer = require("composer")
local json = require("json")
local current_game = require("globals.current_game")
local nav = require("common.nav")
local common_api = require("common.common_api")

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
    print("updatedGame='" .. tostring(updatedGame) .. "'")

    local currentGame = current_game.currentGame
    print("currentGame.id='" .. tostring(currentGame and currentGame.id) .. "'")

    local currentSceneName = composer.getSceneName("current")

    -- If the current scene is the play_game_scene, then just update the game in view
    if currentSceneName == "scenes.play_game_scene" then
       local playGameScene = composer.getScene("scenes.play_game_scene")
        if playGameScene and playGameScene:isValidGameScene() then
            if currentGame and tostring(currentGame.id) == updatedGame then
                print("Current scene is play_game_scene, and it's valid, so updating existing game.")
                playGameScene:refreshGameFromServer()
                return
            else
                print("Current game doesn't match game id. Current = '" .. tostring(currentGame.id) .. "', from push = '" .. updatedGame .. "'")
            end
        end
    else
        print("Current scene is not play_game_scene, so going to play_game_scene:" .. currentSceneName)
    end

    print("Going to play_game_scene with updatedGame: " .. updatedGame)
    M.goToGameByIdFrom(updatedGame, currentSceneName)

end

function M.goToGameByIdFrom(gameId, fromScene)
    local function onFailToGetGame(jsonResp)
        print("Error fetching game with id '" .. tostring(gameId) .. "'")
        print("Response: " .. tostring(jsonResp))
    end

    local function onSuccessToGetGame(gameModel)
        if not gameModel or not gameModel.id then
            print("Invalid game model received from server:" .. json.encode(gameModel))
            return
        end
        current_game.currentGame = gameModel
        nav.goToGame(gameModel, fromScene)
    end

    common_api.getGameById(gameId, true, onSuccessToGetGame, onFailToGetGame, onFailToGetGame, true)
end


return M

