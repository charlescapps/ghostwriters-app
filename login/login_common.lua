
local loadsave = require("lib.loadsave")
local composer = require("composer")
local json = require("json")
local M = {}

local CREDS_FILE = "wordsWithRivalsCreds.json"

M.checkCredentials = function()
	local serverCreds = loadsave.loadTable(CREDS_FILE, system.DocumentsDirectory)

	if serverCreds == nil or serverCreds["user"] == nil or serverCreds["cookie"] == nil then
		print("No wordsWithRivalsCreds.json file found. Opening loggout_out_scene")
		local currentScene = composer.getSceneName( "current" )
		composer.gotoScene( "login.logged_out_scene" )
		composer.removeScene( currentScene, false )
		return nil
	end
	return serverCreds["user"]
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
    loadsave.saveTable({}, CREDS_FILE, system.DocumentsDirectory)
end

M.logoutAndGoToTitle = function()
    M.logout()
    local currentScene = composer.getSceneName("current")
    composer.gotoScene("scenes.title_scene")
    composer.removeScene(currentScene, false)
end

return M