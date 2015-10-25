local M = {}
local json = require("json")
local common_api = require("common.common_api")

M.rival = nil
M.gameType = nil
M.boardSize = nil
M.bonusesType = nil
M.gameDensity = nil
M.specialDict = nil
M.aiType = nil
M.startScene = nil
M.initialBlankTiles = nil
M.initialScryTiles = nil
M.isAcceptGame = nil
M.gameId = nil
M.player2 = nil

M.getNewGameModel = function(user)
	if M.gameType == common_api.SINGLE_PLAYER then
		if not M.aiType or not M.boardSize or not M.bonusesType or not M.gameDensity then
			print ("Missing required field for creating a new Single Player Game: " .. json.encode(M))
			return nil
		end
	elseif M.gameType == common_api.TWO_PLAYER then
		if not M.rival or not M.boardSize or not M.bonusesType or not M.gameDensity then
			print ("Missing required field for creating a new Multi Player Game: " .. json.encode(M))
			return nil
		end
	else
		print("Invalid gameType: " .. tostring(M.gameType))
		return nil
	end

	if M.gameType == common_api.TWO_PLAYER then
		return {
			gameType = M.gameType,
			player1 = user.id,
			player2 = M.rival.id,
			boardSize = M.boardSize,
			bonusesType = M.bonusesType,
			gameDensity = M.gameDensity,
            specialDict = M.specialDict,
            player1Rack = M.getInitialRack()
		}
	else
		return {
			gameType = M.gameType,
			aiType = M.aiType,
			player1 = user.id,
			boardSize = M.boardSize,
			bonusesType = M.bonusesType,
			gameDensity = M.gameDensity,
            specialDict = M.specialDict,
            player1Rack = M.getInitialRack()
		}
	end
end


M.clearAll = function()
	M.rival = nil
    M.gameType = nil
    M.boardSize = nil
    M.bonusesType = nil
    M.gameDensity = nil
	M.aiType = nil
    M.specialDict = nil
    M.startScene = nil
    M.initialBlankTiles = nil
    M.initialScryTiles = nil
    M.isAcceptGame = nil
    M.gameId = nil
    M.player2 = nil
end

function M.getInitialRack()
    local numBlank = M.initialBlankTiles or 0
    local numScry = M.initialScryTiles or 0
    local rackStr = ""
    for i = 1, numBlank do
       rackStr = rackStr .. "*"
    end

    for i = 1, numScry do
       rackStr = rackStr .. "^"
    end

    return rackStr
end

return M