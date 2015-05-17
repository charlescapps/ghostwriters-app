local GameThrive = require("plugin.GameThrivePushNotifications")
local composer = require("composer")
local json = require("json")
local current_game = require("globals.current_game")
local nav = require("common.nav")
local common_api = require("common.common_api")
local login_common = require("login.login_common")
local app_state = require("globals.app_state")

local M = {}

M.ONE_SIGNAL_APP_ID = "479f3518-dbfa-11e4-ac8e-a310507ee73c"
M.ANDROID_PROJECT_NUM = "9329334853"

function M.initOneSignal()
    GameThrive.DisableAutoRegister()
    GameThrive.Init(M.ONE_SIGNAL_APP_ID, M.ANDROID_PROJECT_NUM, M.onReceiveNotification)
end

function M.onReceiveNotification(message, additionalData, isActive)
    local additionalDataStr = json.encode(additionalData)
    print("Received notification, message=" .. message)
    print("additionalData=" .. additionalDataStr)
    if not additionalData or not additionalData.updatedGameId then
        print("Received push notification without updatedGameId field: " .. additionalDataStr)
        return
    end
    
    -- If the app hasn't logged in yet to the main menu (it just started up), then store the callback to be executed later.
    print("one_signal_util - about to process push notification...")
    print("app_state:isAppLoaded = " .. tostring(app_state:isAppLoaded()))
    if app_state:isAppLoaded() then
         print("App is loaded - calling handlePushNotification directly!")
         M.handlePushNotification(isActive, additionalData)
    else
        print("App is not loaded - setting callback for after logged in successfully.")
        app_state:setMainMenuListener(function()
            M.handlePushNotification(isActive, additionalData)
        end)
    end
end

function M.handlePushNotification(isActive, additionalData)
    local updatedGameId = additionalData.updatedGameId
    local currentGame = current_game.currentGame
    local currentSceneName = composer.getSceneName("current")
    print("updatedGameId ID from push= " .. tostring(updatedGameId))
    print("currentGameId= " .. tostring(currentGame and currentGame.id))

    -- If the push notification is for a New Game offer, then accept the offer and load the game
    if additionalData.isGameOffer == "true" then
        M.handleGameOffer(isActive, updatedGameId, currentGame, currentSceneName)
    else
        M.handleGameMove(isActive, updatedGameId, currentGame, currentSceneName)
    end
end

function M.handleGameMove(isActive, updatedGameId, currentGame, currentSceneName)

    -- If the current scene is the play_game_scene for the same Game ID, then just update the game in view
    if currentSceneName == "scenes.play_game_scene" then
        local playGameScene = composer.getScene("scenes.play_game_scene")
        if playGameScene and playGameScene:isValidGameScene() then
            if currentGame and tostring(currentGame.id) == updatedGameId then
                print("Current scene is play_game_scene, and it's valid, so updating existing game.")
                playGameScene:refreshGameFromServer()
                return
            end
        end
    end

    if isActive then
        print("App was active, but not in the game for the push notification, so not sending user to the game with the move...")
        -- TODO: Can we have some kind of "toast" message in this case?
    else
        print("Going to play_game_scene with updatedGameId: " .. updatedGameId)
        M.goToGameByIdFrom(updatedGameId, currentSceneName)
    end
end

function M.handleGameOffer(isActive, updatedGameId, currentGame, currentSceneName)

    if isActive then
    -- If the game is active, then create a "toast" here
        
    else
    -- If the game wasn't active, this means the user clicked on the push notice, so just accept the offer
        M.acceptThenGoToGameById(updatedGameId, currentSceneName)
    end
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

    common_api.getGameById(gameId, true, nil, onSuccessToGetGame, onFailToGetGame, onFailToGetGame, true)
end

function M.acceptThenGoToGameById(gameId, fromScene)
    local function onAcceptGameOfferSuccess()
        M.goToGameByIdFrom(gameId, fromScene)
    end

    local function onAcceptGameOfferFail()
        print("Error accepting game, attempting to go to the 'My Challengers' scene")
        nav.goToSceneFrom(fromScene, "scenes.my_challengers_scene", "fade")
    end

    common_api.acceptGameOffer(gameId, onAcceptGameOfferSuccess, onAcceptGameOfferFail, true)
end

return M

