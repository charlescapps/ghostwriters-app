local common_api = require("common.common_api")
local system = require("system")
local composer = require("composer")
local GameThrive = require("plugin.GameThrivePushNotifications")

local M = {}

function M.getNextUsernameAndLoginIfDeviceFound()
    local deviceId = system.getInfo("deviceID")
    print("Found device ID: " .. deviceId)

    common_api.getNextUsername(deviceId, M.onSuccessListener, M.onFailListener)
end

function M.onSuccessListener(jsonResp)
    local username = jsonResp.nextUsername
    local required = jsonResp.required

    if username and required then
        local deviceId = system.getInfo("deviceID")
        common_api.createNewAccountAndLogin(username, nil, deviceId, M.onLoginSuccess, M.onFailListener)
    else
        composer.gotoScene("login.logged_out_scene")
        local logged_out_scene = composer.getScene("login.logged_out_scene", "fade")
        if logged_out_scene then
            logged_out_scene.nextUsername = jsonResp.nextUsername
        else
            print("Title scene is nil")
        end
    end
end

function M.onFailListener()
    composer.gotoScene("login.logged_out_scene", "fade")
end

function M.onLoginSuccess(user)
    composer.gotoScene("scenes.title_scene", "fade")
    GameThrive.TagPlayer("ghostwriters_id", user.id)
end

return M

