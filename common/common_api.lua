local network = require("network")
local mime = require("mime")
local login_common = require("login.login_common")
local json = require("json")
local M = {}

local SERVER = "http://localhost:8080/api"

local INITIAL_USER = "Initial User"
local INITIAL_PASS = "rL4JDxPyPRprsr6e"

-- Constants
M.SINGLE_PLAYER = "SINGLE_PLAYER"
M.TWO_PLAYER = "TWO_PLAYER"

M.SMALL_SIZE = "TALL"
M.MEDIUM_SIZE = "GRANDE"
M.LARGE_SIZE = "VENTI"

M.LOW_DENSITY = "SPARSE"
M.MEDIUM_DENSITY = "REGULAR"
M.HIGH_DENSITY = "WORD_JUNGLE"

M.FIXED_BONUSES = "FIXED_BONUSES"
M.RANDOM_BONUSES = "RANDOM_BONUSES"

M.RANDOM_AI = "RANDOM_AI"
M.BOOKWORM_AI = "BOOKWORM_AI"
M.PROFESSOR_AI = "PROFESSOR_AI"

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

M.gamesURL = function()
	return SERVER .. "/games"
end

M.movesURL = function()
	return SERVER .. "/moves"
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

M.doApiRequest = function(url, method, body, expectedCode, onSuccess, onFail)

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
				native.showAlert( "Network error", "Please try again." )
				print ("Network error with " .. method .. " to " .. url .. ": " .. json.encode(event));
				return
			end
			local jsonResp = json.decode(event.response)
			if jsonResp == nil then
				native.showAlert("Network error", "Please try again.")
				print("Error - no response returned with " .. method .. " to " .. url .. ": " .. json.encode(event));
				return
			end
			local code = event.status
			if code ~= expectedCode then
				print("Error - unexpected status code " .. code .. "returned with " .. method .. " to " .. url .. ": " .. json.encode(event));
				onFail(jsonResp)
				return
			end
			
			print("SUCCESS - " .. method .. " to " .. url .. " returned: " .. event.response)
			onSuccess(jsonResp)

		end
	end
	return network.request(url, method, listener, params)
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

	M.doApiRequest(url, "GET", nil, 200, onSuccess, onFail)
end

M.createNewGame = function(newGameInput, onSuccess, onFail)
	local url = M.gamesURL()
	M.doApiRequest(url, "POST", json.encode(newGameInput), 201, onSuccess, onFail)
end

M.sendMultiplayerMove = function(moveInput, onSuccess, onFail)
	local url = M.movesURL(gameId)
	M.doApiRequest(url, "POST", json.encode(moveInput), 200, onSuccess, onFail)
end

return M



