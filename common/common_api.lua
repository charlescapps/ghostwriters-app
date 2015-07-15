local network = require("network")
local mime = require("mime")
local common_ui = require("common.common_ui")
local login_common = require("login.login_common")
local json = require("json")
local word_spinner_class = require("classes.word_spinner_class")
local urls = require("common.urls")
local M = {}

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

-- AI usernames
M.MONKEY_USERNAME = "Monkey"
M.BOOKWORM_USERNAME = "Bookworm"
M.PROFESSOR_USERNAME = "Professor"

-- Move types
M.GRAB_TILES = "GRAB_TILES"
M.PLAY_TILES = "PLAY_WORD"
M.PASS = "PASS"
M.RESIGN = "RESIGN"

-- Special dictionaries
M.DICT_POE = "POE"
M.DICT_LOVECRAFT = "LOVECRAFT"
M.DICT_MYTHOS = "MYTHOS"

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

M.getResignMove = function(gameModel, playerId)
    return {
        gameId = gameModel.id,
        playerId = playerId,
        moveType = M.RESIGN,
        start = {r = 0, c = 0},
        dir = "E",
        letters = "",
        tiles = ""
    }
end

M.getBoardSizeCost = function(boardSize)
    if boardSize == M.SMALL_SIZE then
        return 1
    elseif boardSize == M.MEDIUM_SIZE then
        return 3
    elseif boardSize == M.LARGE_SIZE then
        return 5
    end

    print("ERROR - invalid board size passed into getTokenCost: " .. tostring(boardSize))
    return 0
end

M.getDictCost = function(dict)
    if not dict then
        return 0
    elseif dict == M.DICT_POE then
        return 1
    elseif dict == M.DICT_LOVECRAFT then
        return 1
    elseif dict == M.DICT_MYTHOS then
        return 1
    end
    print("Err - invalid dictionary: " .. tostring(dict))
    return 0
end

M.getBonusPoints = function(specialDict)
    if not specialDict then
        return 0
    end
    if specialDict == M.DICT_POE then
        return 25
    elseif specialDict == M.DICT_LOVECRAFT then
        return 25
    elseif specialDict == M.DICT_MYTHOS then
        return 50
    end
end

M.getDictName = function(specialDict)
    if not specialDict then
        return "English"
    end

    if specialDict == M.DICT_POE then
        return "Edgar Allan Poe"
    elseif specialDict == M.DICT_LOVECRAFT then
        return "H.P. Lovecraft"
    elseif specialDict == M.DICT_MYTHOS then
        return "Cthulhu Mythos"
    else
        print ("Error - invalid dictionary type: " .. tostring(specialDict))
        return "English"
    end
end

-- Game results
M.OFFERED = "OFFERED"
M.IN_PROGRESS = "IN_PROGRESS"
M.REJECTED = "REJECTED"
M.PLAYER1_WIN = "PLAYER1_WIN"
M.PLAYER2_WIN = "PLAYER2_WIN"
M.TIE = "TIE"
M.PLAYER1_TIMEOUT = "PLAYER1_TIMEOUT"
M.PLAYER2_TIMEOUT = "PLAYER2_TIMEOUT"
M.PLAYER1_RESIGN = "PLAYER1_RESIGN"
M.PLAYER2_RESIGN = "PLAYER2_RESIGN"

-- Predeclared functions
M.showNetworkError = function()
    common_ui.createInfoModal( "Network error", "Please try again.", nil, 48 )
end

local function getBasicAuthHeader(username, password)
	return "Basic " .. mime.b64(username .. ":" .. password)
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

	return network.request(urls.loginURL(), "POST", listener, params)
end

M.getNextUsername = function(deviceId, onSuccess, onFail, doCreateSpinner)
    local spinner
    if doCreateSpinner then
        spinner = word_spinner_class.new()
        spinner:start()
    end

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
            if spinner then
                spinner:stop()
            end
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
    return network.request(urls.nextUsernameURL(deviceId), "GET", listener, params)
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
			elseif user["errorMessage"] then
				print("An error occurred logging in: " .. user["errorMessage"]);
				onFail(user)
				return
			elseif not M.isValidUser(user) then
                M.showNetworkError()
				print ("Failed to create a new user with username '" .. username .. "' and pass " .. deviceId
					.. "! Event = " .. json.encode(event))
				onFail()
				return				
			end
			local headers = event.responseHeaders
			local cookie = parseCookie(headers["Set-Cookie"])
            print("Received cookie: " .. tostring(cookie))
			if cookie == nil or cookie:len() <= 0 then
                M.showNetworkError()
				print ("Failed to get a cookie from the login response: " .. json.encode(event))
				onFail()
                return
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
	return network.request(urls.usersURL(), "POST", listener, params)
end

M.doApiRequest = function(url, method, body, expectedCode, onSuccess, onFail, onNetworkFail, spinner)

	local cookie = login_common.getCookie()
    if not cookie then
        print("Error - No cookie found stored for current user. Deleting local credentials and logging out.")
        login_common.logout()
        return
    end

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
                if onNetworkFail then
                    onNetworkFail(event)
                end
				print ("Network error with " .. method .. " to " .. url .. ": " .. json.encode(event));
				return
			end
			local jsonResp = json.decode(event.response)
            local code = event.status
            if code == 401 then
                print("Error - 401 (Unauthorized) code for current user. Deleting local cookies and returning to title scene")
                login_common.logout()
                return
			elseif jsonResp == nil then
                if onNetworkFail then
                    onNetworkFail(event)
                end
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

M.doGetWithSpinner = function(url, onSuccess, onFail, onNetworkFail, doCreateSpinner)
    local spinner
    if doCreateSpinner then
        spinner = word_spinner_class.new()
        spinner:start()
    end
    M.doApiRequest(url, "GET", nil, 200, onSuccess, onFail, onNetworkFail, spinner)
end

M.doPostWithSpinner = function(url, jsonTable, expectedStatus, onSuccess, onFail, onNetworkFail, doCreateSpinner)
    local spinner
    if doCreateSpinner then
        spinner = word_spinner_class.new()
        spinner:start()
    end
    M.doApiRequest(url, "POST", json.encode(jsonTable), expectedStatus or 200, onSuccess, onFail, onNetworkFail, spinner)
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
	local url = urls.usersURL() .. "?q=" .. urls.escape(textEntered) .. "&maxResults=" .. maxResults

	M.doApiRequest(url, "GET", nil, 200, onSuccess, onFail, onNetworkFail or M.showNetworkError)
end

M.createNewGame = function(newGameInput, onSuccess, onFail, onNetworkFail, doMakeSpinner)
	local url = urls.gamesURL()
    M.doPostWithSpinner(url, newGameInput, 201, onSuccess, onFail, onNetworkFail or M.showNetworkError, doMakeSpinner)
end

M.sendMove = function(moveInput, onSuccess, onFail, onNetworkFail, doMakeSpinner)
	local url = urls.movesURL()
    local spinner
    if doMakeSpinner then
        spinner = word_spinner_class.new()
        spinner:start()
    end
	M.doApiRequest(url, "POST", json.encode(moveInput), 200, onSuccess, onFail, onNetworkFail or M.showNetworkError, spinner)
end

M.getGameById = function(gameId, includeMoves, currentMove, onSuccess, onFail, onNetworkFail, doMakeSpinner)
    local url = urls.gameByIdURL(gameId, includeMoves, currentMove)
    M.doGetWithSpinner(url, onSuccess, onFail, onNetworkFail, doMakeSpinner)
end

M.getMyGames = function(count, inProgress, includeMoves, onSuccess, onFail, onNetworkFail, doMakeSpinner)
    local url = urls.myGamesURL(count, inProgress, includeMoves)
    M.doGetWithSpinner(url, onSuccess, onFail, onNetworkFail, doMakeSpinner)
end

M.getGamesOfferedToMe = function(count, onSuccess, onFail, onNetworkFail, doMakeSpinner)
    local url = urls.gamesOfferedToMeURL(count)
    M.doGetWithSpinner(url, onSuccess, onFail, onNetworkFail, doMakeSpinner)
end

M.getGamesOfferedByMe = function(count, onSuccess, onFail, onNetworkFail, doMakeSpinner)
    local url = urls.gamesOfferedByMeURL(count)
    M.doGetWithSpinner(url, onSuccess, onFail, onNetworkFail, doMakeSpinner)
end

M.getBestMatch = function(onSuccess, onFail)
    local url = urls.getBestMatchURL()
    M.doGetWithSpinner(url, onSuccess, onFail, onFail, true)
end

M.getUsersWithSimilarRating = function(maxResults, onSuccess, onFail, doCreateSpinner)
    local url = urls.getUsersWithSimilarRatingURL(maxResults)
    M.doGetWithSpinner(url, onSuccess, onFail, onFail, doCreateSpinner)
end

M.acceptGameOffer = function(gameId, numBlankTiles, numScryTiles, onSuccess, onFail, doCreateSpinner)
    local url = urls.getAcceptGameURL(gameId, numBlankTiles, numScryTiles)
    local spinner
    if doCreateSpinner then
        spinner = word_spinner_class.new()
        spinner:start()
    end
    M.doApiRequest(url, "POST", nil, 200, onSuccess, onFail, onFail, spinner)
end

M.rejectGameOffer = function(gameId, onSuccess, onFail, doCreateSpinner)
    local url = urls.getRejectGameURL(gameId)
    local spinner
    if doCreateSpinner then
        spinner = word_spinner_class.new()
        spinner:start()
    end
    M.doApiRequest(url, "POST", nil, 200, onSuccess, onFail, onFail, spinner)
end

M.getUsersWithSimilarRank = function(userId, maxResults, onSuccess, onFail, doCreateSpinner)
    local url = urls.getRanksAroundUserURL(userId, maxResults)
    M.doGetWithSpinner(url, onSuccess, onFail, onFail, doCreateSpinner)
end

M.getBestRankedUsers = function(maxResults, onSuccess, onFail, doCreateSpinner)
    local url = urls.getBestRankedUsersURL(maxResults)
    M.doGetWithSpinner(url, onSuccess, onFail, onFail, doCreateSpinner)
end

M.getRanksNearProfessor = function(maxResults, onSuccess, onFail, doCreateSpinner)
    local url = urls.getRanksNearProfessorURL(maxResults)
    M.doGetWithSpinner(url, onSuccess, onFail, onFail, doCreateSpinner)
end

M.getRanksNearBookworm = function(maxResults, onSuccess, onFail, doCreateSpinner)
    local url = urls.getRanksNearBookwormURL(maxResults)
    M.doGetWithSpinner(url, onSuccess, onFail, onFail, doCreateSpinner)
end

M.getRanksNearMonkey = function(maxResults, onSuccess, onFail, doCreateSpinner)
    local url = urls.getRanksNearMonkeyURL(maxResults)
    M.doGetWithSpinner(url, onSuccess, onFail, onFail, doCreateSpinner)
end

M.getMyGamesSummary = function(onSuccess, onFail, doCreateSpinner)
    local url = urls.myGamesSummaryURL()
    M.doGetWithSpinner(url, onSuccess, onFail, onFail, doCreateSpinner)
end

M.getSelf = function(onSuccess, onFail, doCreateSpinner)
    local url = urls.getSelfURL()
    M.doGetWithSpinner(url, onSuccess, onFail, onFail, false)
end

M.registerPurchase = function(purchase, onSuccess, onFail, doCreateSpinner)
    local url = urls.getPurchaseURL()
    M.doPostWithSpinner(url, purchase, 200, onSuccess, onFail, onFail, doCreateSpinner)
end

M.getDictionary = function(specialDict, onSuccess, onFail, doCreateSpinner)
    local url = urls.getDictionaryURL(specialDict)
    M.doGetWithSpinner(url, onSuccess, onFail, onFail, doCreateSpinner)
end

M.doScryTileAction = function(gameId, onSuccess, onFail, doCreateSpinner)
    local url = urls.getScryActionURL(gameId)
    M.doPostWithSpinner(url, nil, 200, onSuccess, onFail, M.showNetworkError, doCreateSpinner)
end

M.setUserPassword = function(pass, onSuccess, onFail, doCreateSpinner)
    local url = urls.getSetPasswordURL(pass)
    M.doPostWithSpinner(url, nil, 200, onSuccess, onFail, M.showNetworkError, doCreateSpinner)
end

return M