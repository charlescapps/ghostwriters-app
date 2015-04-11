local M = {}

M.currentGame = nil

M.clearAll = function()
	M.currentGame = nil
end

M.isUsersTurn = function(user)
    if not M.currentGame then
        return false
    end

    local game = M.currentGame
    return game.player1Turn and game.player1 == user.id or
           not game.player1Turn and game.player2 == user.id

end


return M