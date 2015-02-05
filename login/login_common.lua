
local loadsave = require("lib.loadsave")
local composer = require("composer")
local common_api = require("common.common_api")
local json = require("json")
local M = {}

local CREDS_FILE = "wordsWithRivalsCreds.json"

M.checkCredentials = function()
	local serverCreds = loadsave.loadTable(CREDS_FILE, system.DocumentsDirectory)

	if serverCreds == nil or serverCreds["user"] == nil or serverCreds["cookie"] == nil then
		print("No wordsWithRivalsCreds.json file found. Opening loggout_out_scene")
		composer.gotoScene( "login.logged_out_scene" )
		return false
	end
	return true
end

local function saveUser(user)
	local serverCreds = {}
	serverCreds.user = user
	loadsave.saveTable(serverCreds, CREDS_FILE, system.DocumentsDirectory)
end

local function saveCookie(cookie)
	local serverCreds = loadsave.loadTable(CREDS_FILE, system.DocumentsDirectory)
	if not serverCreds then
		serverCreds = {}
	end
	serverCreds.cookie = cookie
	loadsave.saveTable(serverCreds, CREDS_FILE, system.DocumentsDirectory)
end

local function createAccountListener(event)
	if event.isError then
		native.showAlert( "Network error", "A network error occurred. Please try again." )
		print "Network error occurred! Event = " .. event
		return
	elseif not event.response then
		native.showAlert("Network error", "A network error occurred. Please try again." )
		print "Empty response received when creating a new user: " .. event
		return
	end

	createdUser = json.decode(event.response)
	if createdUser["errorMessage"] then
		print("Error received from server: " .. createdUser)
		native.showAlert("Error creating new user", createdUser["errorMessage"])
		return
	end

	if not createdUser["username"] or not createdUser["id"] then
		print ("Invalid new user from server, missing username or id: " .. createdUser)
		native.showAlert( "An error occurred creating a new user.", "An error occurred creating a new user. Please try again." )
		return
	end

	print("Saving user to file: " .. createdUser)
	saveUser(createdUser)

end

M.createNewAccount = function(username, email, password)
	local request = common_api.createNewUserRequest(createAccountListener)
end

return M