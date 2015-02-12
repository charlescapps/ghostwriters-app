local network = require("network")
local mime = require("mime")
local login_common = require("login.login_common")
local json = require("json")
local M = {}

local SERVER = "http://localhost:8080/api"

local INITIAL_USER = "Initial User"
local INITIAL_PASS = "rL4JDxPyPRprsr6e"

local function getBasicAuthHeader(username, password)
	return "Basic " .. mime.b64(username .. ":" .. password)
end

local function escape (str)
        str = string.gsub (str, "\n", "\r\n")
        str = string.gsub (str, "([^0-9a-zA-Z ])", -- locale independent
                function (c) return string.format ("%%%02X", string.byte(c)) end)
        str = string.gsub (str, " ", "+")
        return str
end

M.isValidUser = function(user)
	return user ~= nil and user.id and user.username
end

M.loginURL = function()
	return SERVER .. "/login"
end

M.usersURL = function()
	return SERVER .. "/users"
end

M.login = function(username, password, onSuccess, onFail)
	local basic = getBasicAuthHeader(username, password)
	local headers = { ["Authorization"] = basic,
					  ["Content-Type"] = "application/json" 
					}
	local params = { headers = headers,
					 timeout = 20 }
	local listener = function(event)
		if "ended" == event.phase then
			if event.isError or not event.response then
				native.showAlert( "Network error", "A network error occurred. Please try again." )
				print ("Network error occurred logging in as " .. username .. ":" .. password .. "! Event = " .. json.encode(event))
				onFail()
				return
			end
			local user = json.decode(event.response)
			if user["errorMessage"] then
				native.showAlert("Error logging in", user["errorMessage"])
				print("An error occurred logging in: " .. user["errorMessage"]);
				onFail()
				return
			end
			if not M.isValidUser(user) then
				native.showAlert( "Network error", "A network error occurred. Please try again." )
				print ("Failed to get valid user back with username and id when logging in as " .. username .. ":" .. password .. "! Event = " .. json.encode(event))
				onFail()
				return				
			end
			local headers = event.responseHeaders
			local cookie = headers["Set-Cookie"]
			if cookie == nil or cookie:len() <= 0 then
				native.showAlert( "Network error", "A network error occurred. Please try again." )
				print ("Failed to get a cookie from the login response: " .. json.encode(event))
				onFail()
			end
			print("SUCCESS - saving user '" .. user.username .. "' with cookie: " .. cookie)
			login_common.saveUser(user)
			login_common.saveCookie(cookie)
			onSuccess(user)

		end
	end

	return network.request(M.loginURL(), "POST", listener, params)
end

M.createNewAccountAndLogin = function(username, email, password, onSuccess, onFail)

	-- Use basic auth as the Initial User 
	local basic = getBasicAuthHeader(INITIAL_USER, INITIAL_PASS)
	local body = json.encode({username = username, email = email, password = password});
	local headers = { ["Authorization"] = basic,
					  ["Content-Type"] = "application/json" 
					}
	local params = { headers = headers,
					 timeout = 20,
					 body = body }
	local listener = function(event)
		if "ended" == event.phase then
			if event.isError or not event.response then
				native.showAlert( "Network error", "A network error occurred. Please try again." )
				print ("Network error occurred creating a new user '" .. username .. "' with pass '" .. password .. "'" 
					.. "! Event = " .. json.encode(event));
				onFail()
				return
			end
			local user = json.decode(event.response)
			if user["errorMessage"] then
				native.showAlert("Error creating new user", user["errorMessage"])
				print("An error occurred logging in: " .. user["errorMessage"]);
				onFail()
				return
			end
			if not M.isValidUser(user) then
				native.showAlert( "Network error", "A network error occurred. Please try again." )
				print ("Failed to create a new user with username '" .. username .. "' and pass " .. password 
					.. "! Event = " .. json.encode(event))
				onFail()
				return				
			end
			local headers = event.responseHeaders
			local cookie = headers["Set-Cookie"]
			if cookie == nil or cookie:len() <= 0 then
				native.showAlert( "Network error", "A network error occurred. Please try again." )
				print ("Failed to get a cookie from the login response: " .. json.encode(event))
				onFail()
			end
			print("SUCCESS - created user: " .. user.username)
			login_common.saveUser(user)
			login_common.saveCookie(cookie)
			onSuccess(user)

		end
	end
	return network.request(M.usersURL(), "POST", listener, params)
end

M.isValidUsernameChars = function(text)
	if not string.match( text, "[a-zA-Z0-9_ \\-]+" ) then
		return {
			["error"] = "Usernames can only contain alphanumeric characters, spaces, '-', and '_'"
		}
	end
	return { ["success"] = "Username is valid" }
end

M.searchForUsers = function(textEntered, maxResults, onSuccess, onFail)
	
	local usernameError = M.isValidUsernameChars(textEntered)

	-- If the user enters invalid characters, don't bother doing a network request, return 0 results.
	if (usernameError and usernameError.error) then
		onSuccess({}) -- 0 results returned if the user enters bad characters
		return
	end

	-- Sanitize input and construct URL with query params.
	local url = M.usersURL() .. "?q=" .. escape(textEntered) .. "&maxResults=" .. maxResults

	-- Use basic auth as the Initial User 
	local cookie = login_common.getCookie()
	local headers = { ["Cookie"] = cookie,
					  ["Content-Type"] = "application/json" 
					}
	local params = { headers = headers,
					 timeout = 30,
					 body = body }
	local listener = function(event)
		if "ended" == event.phase then
			if event.isError or not event.response then
				native.showAlert( "Network error", "A network error occurred. Please try again." )
				print ("Network error occurred searching for users with GET /users! Event = " .. json.encode(event));
				onFail(event)
				return
			end
			local userList = json.decode(event.response)
			if userList == nil then
				native.showAlert("Error searching for users", "Please try again")
				print("An error occurred doing GET /users: " .. json.encode(event));
				onFail(event)
				return
			end
			if userList["errorMessage"] then
				native.showAlert("Error searching for users", userList["errorMessage"])
				print("An error occurred doing GET /users: " .. userList["errorMessage"]);
				onFail(event)
				return
			end
			if not userList["users"] then
				native.showAlert( "Network error", "A network error occurred. Please try again." )
				print ("Failed to GET /users! Response has no 'users' field. Event = " .. json.encode(event))
				onFail(event)
				return				
			end
			print("SUCCESS - GET /users returned: " .. json.encode(userList["users"]))
			onSuccess(userList["users"])

		end
	end
	return network.request(url, "GET", listener, params)
end

return M