local M = {}
local json = require("json")
local common_api = require("common.common_api")

M.rival = nil
M.boardSize = nil
M.bonusesType = nil
M.gameDensity = nil

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
			gameDensity = M.gameDensity
		}
	else
		return {
			gameType = M.gameType,
			aiType = M.aiType,
			player1 = user.id,
			boardSize = M.boardSize,
			bonusesType = M.bonusesType,
			gameDensity = M.gameDensity
		}
	end
end


M.clearAll = function()
	M.rival = nil
	M.boardSize = nil
	M.bonusesType = nil
	M.gameDensity = nil
	M.gameType = nil
	M.aiType = nil
end

return M