local M = {}
local json = require("json")
local login_common = require("login.login_common")

M.rival = nil
M.boardSize = nil
M.bonusesType = nil
M.gameDensity = nil

M.getNewGameModel = function()
	if not M.rival or not M.boardSize or not M.bonusesType or not M.gameDensity then
		print ("Missing required field for creating a new Game: " .. json.encode(M))
		return nil
	end

	local user = login_common.checkCredentials()

	return {
		gameType = M.gameType,
		aiType = M.aiType,
		player1 = user.id,
		player2 = M.rival.id,
		boardSize = M.boardSize,
		bonusesType = M.bonusesType,
		gameDensity = M.gameDensity
	}
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