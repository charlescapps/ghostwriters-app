local loadsave = require("lib.loadsave")
local composer = require("composer")
local nav = require("common.nav")
local json = require("json")
local system = require("system")

local M = {}

local CREDS_FILE = "ghostWritersUserCreds.json"

local CREDS_KEY = "USER_CREDENTIALS_KEY"
M.CREDS_KEY = CREDS_KEY

M.fetchCredentials = function()
    local creds = M.fetchCredentialsRaw()

	if not M.isValidCreds(creds) then
		print("No ghostWritersUserCreds.json file found, or data is missing username/cookie.")
        print("Data found = " .. json.encode(creds))
        loadsave.saveTable({}, CREDS_FILE, system.DocumentsDirectory)
		creds = nil
    end

	return creds
end

M.fetchCredentialsRaw = function()
    local creds = composer.getVariable(CREDS_KEY)

    if not M.isValidCreds(creds) then
        print ("Server creds not found in composer variable or missing data. Falling back to loading from file...")
        creds = loadsave.loadTable(CREDS_FILE, system.DocumentsDirectory)
        composer.setVariable(CREDS_KEY, creds or {})
    end

    return creds
end

M.isValidCreds = function(creds)
   return creds and M.isValidUser(creds["user"]) and creds["cookie"] and true
end

M.dumpToLoggedOutScene = function(fromScene)
    nav.goToSceneFrom(fromScene, "login.create_user_scene")
end

M.saveCreds = function(creds)
    loadsave.saveTable(creds or {}, CREDS_FILE, system.DocumentsDirectory)
    composer.setVariable(CREDS_KEY, creds or {})
end

M.getUser = function()
	local creds = M.fetchCredentialsRaw()
    return creds and M.isValidUser(creds["user"]) and creds["user"]
end

M.getCookie = function()
    local creds = M.fetchCredentialsRaw()
    return creds and creds["cookie"]
end

M.logout = function()
    local oldUser = M.getUser()
    M.saveCreds({ cookie = nil, user = oldUser })

    if oldUser then
        composer.gotoScene("login.welcome_scene")
    else
        composer.gotoScene("login.create_user_scene")
    end
end

M.updateStoredUser = function(updatedUser)
    local creds = M.fetchCredentials()
    if not creds or not updatedUser then
        return
    end
    creds.user = updatedUser

    M.saveCreds(creds)
end

M.isValidUser = function(user)
    return user and user.id and (user.tokens ~= nil) and user.username and true
end

return M