local common_api = require("common.common_api")
local device_id_backup = require("login.device_id_backup")
local system = require("system")
local composer = require("composer")
local OneSignal = require("plugin.OneSignal")
local app_state = require("globals.app_state")
local login_common = require("login.login_common")

local M = {}

function M.getNextUsernameAndLoginIfDeviceFound()
    if not app_state:isAppLoaded() then
        -- If valid credentials are present, then skip to the Main Menu.
        local creds = login_common.fetchCredentialsRaw()
        if login_common.isValidCreds(creds) then
            composer.gotoScene("scenes.title_scene", "fade")
            return
        end
        -- Else, use the deviceId to determine the username, if this device is already registered.
        local deviceId = device_id_backup.getDeviceId()
        print("Found device ID: " .. tostring(deviceId))
        common_api.getNextUsername(deviceId, M.onSuccessListener, M.onFailListener)
    else
        app_state:callAppLoadedListener()
    end
end

function M.onSuccessListener(jsonResp)
    local username = jsonResp.nextUsername
    local required = jsonResp.required

    if username and required then
        -- Device already registered
        local deviceId = device_id_backup.getDeviceId()
        common_api.createNewAccountAndLogin(username, nil, deviceId, M.onLoginSuccess, M.onFailListener)
    else
        composer.gotoScene("login.create_user_scene", "fade")
        local create_user_scene = composer.getScene("login.create_user_scene")
        if create_user_scene then
            create_user_scene.nextUsername = jsonResp.nextUsername
        else
            print("Error - Logged out scene is nil")
        end
    end
end

function M.onFailListener()
    local user = login_common.getUser()
    if user then
        composer.gotoScene("login.welcome_scene", "fade")
    else
        composer.gotoScene("login.create_user_scene", "fade")
    end
end

function M.onLoginSuccess(user)
    composer.gotoScene("scenes.title_scene", "fade")
    OneSignal.TagPlayer("ghostwriters_id", user.id)
    app_state:callAppLoadedListener()
end

return M

