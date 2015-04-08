local network = require("network")
local mime = require("mime")
local login_common = require("login.login_common")
local json = require("json")
local word_spinner_class = require("classes.word_spinner_class")
local M = {}

local SERVER = "https://ghostwriters.herokuapp.com/api"
--local SERVER = "http://10.0.0.13:8080/api"

local INITIAL_USER = "Initial User"
local INITIAL_PASS = "rL4JDxPyPRprsr6e"

local DEFAULT_TIMEOUT = 30

-- Constants
-- Meta stuff
M.MAX_GAMES_IN_PROGRESS = 10

-- Game types
M.SINGLE_PLAYER = "SINGLE_PLAYER"
M.TWO_PLAYER = "TWO_PLAYER"

-- Board sizes
M.SMALL_SIZE = "TALL"
M.MEDIUM_SIZE = "GRANDE"
M.LARGE_SIZE = "VENTI"

-- Game densities
M.LOW_DENSITY = "SPARSE"
M.MEDIUM_DENSITY = "REGULAR"
M.HIGH_DENSITY = "WORD_JUNGLE"

-- Bonuses types
M.FIXED_BONUSES = "FIXED_BONUSES"
M.RANDOM_BONUSES = "RANDOM_BONUSES"

-- AI types
M.RANDOM_AI = "RANDOM_AI"
M.BOOKWORM_AI = "BOOKWORM_AI"
M.PROFESSOR_AI = "PROFESSOR_AI"

-- Move types
M.GRAB_TILES = "GRAB_TILES"
M.PLAY_TILES = "PLAY_WORD"
M.PASS = "PASS"

M.getPassMove = function(gameModel, playerId)
    return {
        gameId = gameModel.id,
        playerId = playerId,
        moveType = M.PASS,
        start = {r = 0, c = 0},
        dir = "E",
        letters = "",
        tiles = ""
    }
end

-- Game results
M.IN_PROGRESS = "IN_PROGRESS"
M.PLAYER1_WIN = "PLAYER1_WIN"
M.PLAYER2_WIN = "PLAYER2_WIN"
M.TIE = "TIE"
M.PLAYER1_TIMEOUT = "PLAYER1_TIMEOUT"
M.PLAYER2_TIMEOUT = "PLAYER2_TIMEOUT"

-- Predeclared functions
M.showNetworkError = function()
    native.showAlert( "Network error", "A network error occurred. Please try again.", {"OK"} )
end

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

local function parseCookie(setCookieHeader)
    if not setCookieHeader then
        return nil
    end
    local startI, endI = setCookieHeader:find(";")
    if not startI or startI == 1 then
        return setCookieHeader
    end
    return setCookieHeader:sub(1, startI - 1)

end

M.isValidUser = function(user)
	return user ~= nil and user.id and user.username
end

-- Functions to construct URLs
-- May be a constant URL, or may require query params
M.loginURL = function()
	return SERVER .. "/login"
end

M.usersURL = function()
	return SERVER .. "/users"
end

M.nextUsernameURL = function(deviceId)
    local url =  M.usersURL() .. "/nextUsername"
    if deviceId then
        return url .. "?deviceId=" .. escape(deviceId)
    else
        return url
    end
end

M.gamesURL = function()
	return SERVER .. "/games"
end

M.myGamesURL = function(count, inProgress, includeMoves)
    local baseURL = M.gamesURL()
    local url = baseURL .. "?count=" .. count .. "&inProgress=" .. tostring(inProgress)
    if includeMoves then
        url = url .. "&includeMoves=true"
    end
    return url
end

M.movesURL = function()
	return SERVER .. "/moves"
end

M.getBestMatchURL = function()
    return SERVER .. "/users/bestMatch"
end

M.getUsersWithSimilarRatingURL = function(maxResults)
    return SERVER .. "/users/similarRating?maxResults=" .. escape(maxResults)
end

M.login = function(username, password, onSuccess, onFail)
	local basic = getBasicAuthHeader(username, password)
	local headers = { ["Authorization"] = basic,
					  ["Content-Type"] = "application/json" 
					}
	local params = { headers = headers,
					 timeout = DEFAULT_TIMEOUT }
	local listener = function(event)
		if "ended" == event.phase then
			if event.isError or not event.response then
				M.showNetworkError()
				print ("Network error occurred logging in as " .. username .. ":" .. password .. "! Event = " .. json.encode(event))
				onFail()
				return
			end
			local user = json.decode(event.response)
			if user["errorMessage"] then
				native.showAlert("Error logging in", user["errorMessage"], {"OK"})
				print("An error occurred logging in: " .. user["errorMessage"]);
				onFail()
				return
			end
			if not M.isValidUser(user) then
                M.showNetworkError()
				print ("Failed to get valid user back with username and id when logging in as " .. username .. ":" .. password .. "! Event = " .. json.encode(event))
				onFail()
				return				
			end
			local headers = event.responseHeaders
			local cookie = parseCookie(headers["Set-Cookie"])
            print("Received cookie: " .. cookie)
			if cookie == nil or cookie:len() <= 0 then
                M.showNetworkError()
				print ("Failed to get a cookie from the login response: " .. json.encode(event))
				onFail()
			end
			print("SUCCESS - saving user '" .. user.username .. "' with cookie: " .. cookie)
            local creds = {
                user = user,
                cookie = cookie
            }
			login_common.saveCreds(creds)
			onSuccess(user)
		end
	end

	return network.request(M.loginURL(), "POST", listener, params)
end

M.getNextUsername = function(deviceId, onSuccess, onFail)
    -- Use basic auth as the Initial User
    local basic = getBasicAuthHeader(INITIAL_USER, INITIAL_PASS)
    local headers = {
        ["Authorization"] = basic,
        ["Content-Type"] = "application/json"
    }
    local params = { headers = headers,
        timeout = 5, -- shorter timeout.
        body = nil }

    local listener = function(event)
        if "ended" == event.phase then
            if event.isError or not event.response then
                print ("Network error occurred: " .. json.encode(event))
                onFail()
                return
            end
            local nextUsername = json.decode(event.response)
            if not nextUsername then
                print("Invalid JSON returned from server: " .. json.encode(event))
                onFail()
                return
            elseif nextUsername["errorMessage"] then
                print("An error occurred getting next username: " .. nextUsername["errorMessage"]);
                onFail()
                return
            elseif not nextUsername.nextUsername then
                print("No username returned from nextUsername endpoint: " .. json.encode(event))
                onFail()
                return
            end
            print("SUCCESS - got next username: " .. json.encode(nextUsername))
            onSuccess(nextUsername)

        end
    end
    return network.request(M.nextUsernameURL(deviceId), "GET", listener, params)
end

M.createNewAccountAndLogin = function(username, email, deviceId, onSuccess, onFail)

	-- Use basic auth as the Initial User 
	local basic = getBasicAuthHeader(INITIAL_USER, INITIAL_PASS)
	local body = json.encode({username = username, email = email, deviceId = deviceId });
	local headers = { ["Authorization"] = basic,
					  ["Content-Type"] = "application/json" 
					}
	local params = { headers = headers,
					 timeout = DEFAULT_TIMEOUT,
					 body = body }
	local listener = function(event)
		if "ended" == event.phase then
			if event.isError or not event.response then
                M.showNetworkError()
				print ("Network error occurred creating a new user '" .. username .. "' with pass '" .. deviceId .. "'"
					.. "! Event = " .. json.encode(event));
				onFail()
				return
			end
			local user = json.decode(event.response)
			if not user then
                M.showNetworkError()
				print("Invalid JSON returned from server: " .. json.encode(event))
				onFail()
				return
			end
			if user["errorMessage"] then
				native.showAlert("Error creating new user", user["errorMessage"], {"OK"})
				print("An error occurred logging in: " .. user["errorMessage"]);
				onFail()
				return
			end
			if not M.isValidUser(user) then
                M.showNetworkError()
				print ("Failed to create a new user with username '" .. username .. "' and pass " .. deviceId
					.. "! Event = " .. json.encode(event))
				onFail()
				return				
			end
			local headers = event.responseHeaders
			local cookie = parseCookie(headers["Set-Cookie"])
            print("Received cookie: " .. cookie)
			if cookie == nil or cookie:len() <= 0 then
                M.showNetworkError()
				print ("Failed to get a cookie from the login response: " .. json.encode(event))
				onFail()
			end
			print("SUCCESS - created user: " .. user.username)
            local creds = {
                user = user,
                cookie = cookie
            }
			login_common.saveCreds(creds)
			onSuccess(user)
		end
	end
	return network.request(M.usersURL(), "POST", listener, params)
end

M.doApiRequest = function(url, method, body, expectedCode, onSuccess, onFail, onNetworkFail, spinner)

	local cookie = login_common.getCookie()
	local headers = { ["Cookie"] = cookie,
					  ["Content-Type"] = "application/json" 
					}
	local params = { headers = headers,
					 timeout = 30,
					 body = body }
	local listener = function(event)
		if "ended" == event.phase then
            -- If we have a spinner, then stop it when the request is finished.
            if spinner then
                spinner:stop()
            end
			if event.isError or not event.response then
                onNetworkFail(event)
				print ("Network error with " .. method .. " to " .. url .. ": " .. json.encode(event));
				return
			end
			local jsonResp = json.decode(event.response)
            local code = event.status
            if code == 401 then
                print("Error - 401 (Unauthorized) code for current user. Deleting local cookies and returning to title scene")
                native.showAlert("Authorization error", "Your device doesn't have valid credentials stored. Logging out...", {"OK"})
                login_common.logout()
                return
			elseif jsonResp == nil then
                onNetworkFail()
				print("Error - no response returned with " .. method .. " to " .. url .. ": " .. json.encode(event));
				return
			end

			if code ~= expectedCode then
				print("Error - unexpected status code (" .. code .. ") returned with " .. method .. " to " .. url);
                print("Response - " .. json.encode(event.response))
				onFail(jsonResp)
				return
			end
			
			print("SUCCESS - " .. method .. " to " .. url .. " returned: " .. event.response)
			onSuccess(jsonResp)

		end
    end
    print("Doing " .. method .. " to " .. url .. " with request body:\n" .. tostring(body))
    print("Sending Headers: " .. json.encode(headers))
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

M.searchForUsers = function(textEntered, maxResults, onSuccess, onFail, onNetworkFail)
	
	local usernameError = M.isValidUsernameChars(textEntered)

	-- If the user enters invalid characters, don't bother doing a network request, return 0 results.
	if (usernameError and usernameError.error) then
		onSuccess({}) -- 0 results returned if the user enters bad characters
		return
	end

	-- Sanitize input and construct URL with query params.
	local url = M.usersURL() .. "?q=" .. escape(textEntered) .. "&maxResults=" .. maxResults

	M.doApiRequest(url, "GET", nil, 200, onSuccess, onFail, onNetworkFail or M.showNetworkError)
end

M.createNewGame = function(newGameInput, onSuccess, onFail, onNetworkFail, doMakeSpinner)
	local url = M.gamesURL()
    local spinner
    if doMakeSpinner then
        spinner = word_spinner_class.new()
        spinner:start()
    end
	M.doApiRequest(url, "POST", json.encode(newGameInput), 201, onSuccess, onFail, onNetworkFail or M.showNetworkError, spinner)
end

M.sendMove = function(moveInput, onSuccess, onFail, onNetworkFail, doMakeSpinner)
	local url = M.movesURL()
    local spinner
    if doMakeSpinner then
        spinner = word_spinner_class.new()
        spinner:start()
    end
	M.doApiRequest(url, "POST", json.encode(moveInput), 200, onSuccess, onFail, onNetworkFail or M.showNetworkError, spinner)
end

M.getMyGames = function(count, inProgress, includeMoves, onSuccess, onFail, onNetworkFail, doMakeSpinner)
    local url = M.myGamesURL(count, inProgress, includeMoves)
    local spinner
    if doMakeSpinner then
        spinner = word_spinner_class.new()
        spinner:start()
    end
    M.doApiRequest(url, "GET", "", 200, onSuccess, onFail, onNetworkFail, spinner)

end

M.getBestMatch = function(onSuccess, onFail)
    local url = M.getBestMatchURL()
    local spinner = word_spinner_class.new()
    spinner:start()
    M.doApiRequest(url, "GET", nil, 200, onSuccess, onFail, onFail, spinner)
end

M.getUsersWithSimilarRating = function(maxResults, onSuccess, onFail, doCreateSpinner)
    local url = M.getUsersWithSimilarRatingURL(maxResults)
    local spinner
    if doCreateSpinner then
        spinner = word_spinner_class.new()
        spinner:start()
    end
    M.doApiRequest(url, "GET", nil, 200, onSuccess, onFail, onFail, spinner)
end

return M



