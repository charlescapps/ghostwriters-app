
local loadsave = require("lib.loadsave")
local composer = require("composer")
local M = {}

M.checkCredentials = function()
	local serverCreds = loadsave.loadTable("wordsWithRivalsCreds.json", system.DocumentsDirectory)

	if serverCreds == nil or serverCreds["user"] == nil or serverCreds["cookie"] == nil then
		print("No wordsWithRivalsCreds.json file found. Opening loggout_out_scene")
		composer.gotoScene( "login.logged_out_scene" )
		return false
	end
	return true
end


M.createNewAccount = function(username, email, password)

end

return M