
local loadsave = require("lib.loadsave")
local composer = require("composer")
local nav = require("common.nav")
local json = require("json")
local M = {}

local CREDS_FILE = "ghostWritersUserCreds.json"

local CREDS_KEY = "USER_CREDENTIALS_KEY"
M.CREDS_KEY = CREDS_KEY

M.fetchCredentials = function()
    local serverCreds = composer.getVariable(CREDS_KEY)

    if not serverCreds or not serverCreds["user"] or not serverCreds["cookie"] then
        print ("Server creds not found in composer variable or missing data. Falling back to loading from file...")
	    serverCreds = loadsave.loadTable(CREDS_FILE, system.DocumentsDirectory)
        composer.setVariable(CREDS_KEY, serverCreds)
    end

	if not serverCreds or not serverCreds["user"] or not serverCreds["cookie"] then
		print("No ghostWritersUserCreds.json file found, or data is corrupt.")
        print("Data found = " .. json.encode(serverCreds))
		return nil
    end

	return serverCreds
end

M.dumpToLoggedOutScene = function(fromScene)
    nav.goToSceneFrom(fromScene, "login.logged_out_scene")
end

M.saveUser = function(user)
	local serverCreds = {}
	serverCreds.user = user
	loadsave.saveTable(serverCreds, CREDS_FILE, system.DocumentsDirectory)
end

M.saveCookie = function(cookie)
	local serverCreds = loadsave.loadTable(CREDS_FILE, system.DocumentsDirectory)
	if not serverCreds then
		serverCreds = {}
	end
	serverCreds.cookie = cookie
	loadsave.saveTable(serverCreds, CREDS_FILE, system.DocumentsDirectory)
end

M.getUser = function()
	local serverCreds = loadsave.loadTable(CREDS_FILE, system.DocumentsDirectory)
	if not serverCreds then
		return nil
	end
	return serverCreds["user"]
end

M.getCookie = function()
	local serverCreds = loadsave.loadTable(CREDS_FILE, system.DocumentsDirectory)
	if not serverCreds then
		return nil
	end
	return serverCreds["cookie"]
end

M.logout = function()
    composer.setVariable(CREDS_KEY, nil)
    loadsave.saveTable({}, CREDS_FILE, system.DocumentsDirectory)
end

M.logoutAndGoToTitle = function()
    M.logout()
    local currentScene = composer.getSceneName("current")
    composer.gotoScene("scenes.title_scene")
    composer.removeScene(currentScene, false)
end

return M