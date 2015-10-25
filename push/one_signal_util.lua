local OneSignal = require("plugin.OneSignal")
local composer = require("composer")
local json = require("json")
local current_game = require("globals.current_game")
local nav = require("common.nav")
local common_api = require("common.common_api")
local app_state = require("globals.app_state")
local toast = require("classes.toast")
local game_helpers = require("common.game_helpers")
local login_common = require("login.login_common")
local one_signal_player_id_queue = require("push.one_signal_player_id_queue")

local M = {}

M.ONE_SIGNAL_APP_ID = "479f3518-dbfa-11e4-ac8e-a310507ee73c"
M.ANDROID_PROJECT_NUM = "9329334853"

function M.initOneSignal()
    OneSignal.DisableAutoRegister()
    OneSignal.Init(M.ONE_SIGNAL_APP_ID, M.ANDROID_PROJECT_NUM, M.onReceiveNotification)
    M.setIdsAvailableCallback()
end

function M.setIdsAvailableCallback()
    OneSignal.IdsAvailableCallback(M.onIdsAvailable)
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
         M.handlePushNotification(isActive, additionalData, message)
    else
        print("App is not loaded - setting callback for after logged in successfully.")
        app_state:setAppLoadedListener(function()
            M.handlePushNotification(isActive, additionalData, message)
        end)
    end
end

function M.handlePushNotification(isActive, additionalData, message)
    local updatedGameId = additionalData.updatedGameId
    local currentGame = current_game.currentGame
    local currentSceneName = composer.getSceneName("current")
    print("updatedGameId ID from push= " .. tostring(updatedGameId))
    print("currentGameId= " .. tostring(currentGame and currentGame.id or "none"))

    -- If the push notification is for a New Game offer, then accept the offer and load the game
    if additionalData.isGameOffer == "true" then
        M.handleGameOffer(isActive, additionalData, message)
    else
        M.handleGameMove(isActive, updatedGameId, currentGame, currentSceneName, message)
    end
end

function M.handleGameMove(isActive, updatedGameId, currentGame, currentSceneName, message)

    -- If the current scene is the play_game_scene for the same Game ID, then just update the game in view
    if currentSceneName == "scenes.play_game_scene" then
        local playGameScene = composer.getScene("scenes.play_game_scene")
        if playGameScene and playGameScene:isValidGameScene() then
            if currentGame and tostring(currentGame.id) == updatedGameId then
                if isActive then
                    print("Updating active game after receiving push notification.")
                    playGameScene:refreshGameFromServer()
                end
                -- The onApplicationResume listener will handle this case.
                return
            end
        end
    end

    if isActive then
        print("Showing toast for user to touch and go to the game...")
        local toastText = message .. "\n(Touch to go)"
        toast.new(toastText, nil, function()
            print("Going to play_game_scene with updatedGameId: " .. updatedGameId)
            M.goToGameByIdFrom(updatedGameId, currentSceneName)
        end)
    else
        print("Going to play_game_scene with updatedGameId: " .. tostring(updatedGameId))
        M.goToGameByIdFrom(updatedGameId, currentSceneName)
    end
end

function M.handleGameOffer(isActive, data, message)

    if isActive then
    -- If ghostwriters is active, then create a "toast" so as to not suddenly interrupt what the player is doing.
        print("Showing toast for new game offer.")
        local toastText = tostring(message) .. "\n(Touch to accept)"
        toast.new(toastText, nil, function()
            game_helpers.goToAcceptGameScene(data.updatedGameId,
                                             data.boardSize,
                                             data.specialDict,
                                             data.gameDensity,
                                             data.bonusesType,
                                             data.player2)
        end)
    else
    -- If ghostwriters isn't active, this means the user clicked on the push notice, so just accept the offer
        print("Push notification - ghostwriters not active - going to accept game scene directly.")
        game_helpers.goToAcceptGameScene(data.updatedGameId,
            data.boardSize,
            data.specialDict,
            data.gameDensity,
            data.bonusesType,
            data.player2)
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

function M.onIdsAvailable(playerId, pushToken)
    if not playerId or not pushToken then
        print("[INFO] OneSignal.IdsAvailable() - playerId or pushToken is nil, so not registering with server yet: playerId = " ..
            tostring(playerId) .. ", pushToken = " .. tostring(pushToken))
        return
    end

    local currentUser = login_common.getUser()
    local userId = currentUser and currentUser.id

    local oneSignalInfo = {
        userId = userId,
        oneSignalPlayerId = playerId
    }

    if not userId then
        print("[ERROR] currentUser is nil or has no id field from login_common, so cannot update OneSignalId.")
        one_signal_player_id_queue.saveOneSignalInfo(oneSignalInfo)
        return
    end

    local function onSuccess()
        print("[INFO] SUCCESS - updated player's one signal ID on Ghostwriters server: " .. tostring(oneSignalInfo.oneSignalPlayerId))
        one_signal_player_id_queue.clearOneSignalInfo()
    end

    local function onFail()
        print("[ERROR] - failed to update player's one signal ID! userId = " .. tostring(userId) .. ", playerId = " .. tostring(playerId))
        one_signal_player_id_queue.saveOneSignalInfo(oneSignalInfo)
    end

    common_api.updateOneSignalInfo(oneSignalInfo, onSuccess, onFail)

end

function M.updateOneSignalInfoFromQueue()
    local oneSignalInfo = one_signal_player_id_queue.getOneSignalInfo()
    if not oneSignalInfo then
        return
    end

    -- If there's no userId stored, that means the user wasn't logged in at the time,
    -- so we must add the user ID and assume it's the currently logged in user.
    if not oneSignalInfo.userId then
        local currentUser = login_common.getUser()
        oneSignalInfo.userId = currentUser and currentUser.id
        if not oneSignalInfo.userId then
            print ("[ERROR] No currently logged in user, cannot update one signal info.")
            return
        end
    end

    local function onSuccess()
        print("[INFO] SUCCESS - updated player's one signal ID on Ghostwriters server: "  .. json.encode(oneSignalInfo))
        one_signal_player_id_queue.clearOneSignalInfo()
    end

    local function onFail()
        print("[ERROR] - failed to update player's one signal ID: " .. json.encode(oneSignalInfo))
    end

    common_api.updateOneSignalInfo(oneSignalInfo, onSuccess, onFail)

end

return M

