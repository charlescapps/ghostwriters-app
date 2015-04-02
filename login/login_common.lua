
local loadsave = require("lib.loadsave")
local composer = require("composer")
local nav = require("common.nav")
local json = require("json")
local M = {}

local CREDS_FILE = "ghostWritersUserCreds.json"

local CREDS_KEY = "USER_CREDENTIALS_KEY"
M.CREDS_KEY = CREDS_KEY

M.fetchCredentials = function()
    local creds = composer.getVariable(CREDS_KEY)

    if not M.isValidCreds(creds) then
        print ("Server creds not found in composer variable or missing data. Falling back to loading from file...")
	    creds = loadsave.loadTable(CREDS_FILE, system.DocumentsDirectory)
        composer.setVariable(CREDS_KEY, creds or {})
    end

	if not M.isValidCreds(creds) then
		print("No ghostWritersUserCreds.json file found, or data is corrupt.")
        print("Data found = " .. json.encode(creds))
        loadsave.saveTable({}, CREDS_FILE, system.DocumentsDirectory)
		creds = nil
    end

	return creds
end

M.isValidCreds = function(creds)
   return creds and creds["user"] and creds["cookie"]
end

M.dumpToLoggedOutScene = function(fromScene)
    nav.goToSceneFrom(fromScene, "login.logged_out_scene")
end

M.saveCreds = function(creds)
    loadsave.saveTable(creds or {}, CREDS_FILE, system.DocumentsDirectory)
    composer.setVariable(CREDS_KEY, creds or {})
end

M.getUser = function()
	local creds = M.fetchCredentials()
    return creds and creds["user"]
end

M.getCookie = function()
    local creds = M.fetchCredentials()
    return creds and creds["cookie"]
end

M.logout = function()
    M.saveCreds({})
    composer.gotoScene("login.logged_out_scene")
end

M.fetchCredentialsOrLogout = function(sceneName)
    local currentScene = composer.getSceneName("current")
    if not currentScene == sceneName then
        return
    end

    local creds = M.fetchCredentials()
    if creds then
        return creds
    end

    M.logout()
    composer.removeHidden()
end

return M