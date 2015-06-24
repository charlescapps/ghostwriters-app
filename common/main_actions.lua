local common_api = require("common.common_api")
local system = require("system")
local composer = require("composer")
local OneSignal = require("plugin.OneSignal")
local app_state = require("globals.app_state")

local M = {}

function M.getNextUsernameAndLoginIfDeviceFound()
    local deviceId = system.getInfo("deviceID")
    print("Found device ID: " .. deviceId)

    if not app_state:isAppLoaded() then
        common_api.getNextUsername(deviceId, M.onSuccessListener, M.onFailListener)
    else
        app_state:callAppLoadedListener()
    end
end

function M.onSuccessListener(jsonResp)
    local username = jsonResp.nextUsername
    local required = jsonResp.required

    if username and required then
        local deviceId = system.getInfo("deviceID")
        common_api.createNewAccountAndLogin(username, nil, deviceId, M.onLoginSuccess, M.onFailListener)
    else
        composer.gotoScene("login.logged_out_scene", "fade")
        local logged_out_scene = composer.getScene("login.logged_out_scene")
        if logged_out_scene then
            logged_out_scene.nextUsername = jsonResp.nextUsername
        else
            print("Error - Logged out scene is nil")
        end
    end
end

function M.onFailListener()
    composer.gotoScene("login.logged_out_scene", "fade")
end

function M.onLoginSuccess(user)
    composer.gotoScene("scenes.title_scene", "fade")
    OneSignal.TagPlayer("ghostwriters_id", user.id)
    app_state:callAppLoadedListener()
end

return M

