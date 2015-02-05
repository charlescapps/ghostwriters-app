local network = require("network")
local mime = require("mime")
local M = {}

M.SERVER = "http://localhost:8080/api"

M.INITIAL_USER = "Initial User"
M.INITIAL_PASS = "rL4JDxPyPRprsr6e"

M.loginURL = function()
	return M.SERVER + "/login"
end

M.createNewUserRequest = function(endedListener)
	local basic = "Basic " .. mime.b64(M.INITIAL_USER .. ":" .. M.INITIAL_PASS)
	local headers = { ["Authorization"] = basic,
					  ["Content-Type"] = "application/json" 
					}
	local params = { headers = headers,
					 timeout = 20 }
	local listener = function(event)
		if "ended" == event.phase then
			endedListener(event)
		end
	end

	return network.request(M.loginURL(), "POST", listener, params)

end