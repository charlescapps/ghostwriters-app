local json = require("json")

local M = {}

function M.isValidGame(game)
    return game and game.id and game.player1 and game.player2 and game.player1Model and game.player2Model and true
end

function M.isValidGameUpdate(currentGame, updatedGame)
    if not M.isValidGame(currentGame) then
        print("Current game isn't a valid game: " .. json.encode(currentGame))
        return false
    end
    if not M.isValidGame(updatedGame) then
        print("Updated game isn't a valid game: " .. json.encode(updatedGame))
        return false
    end
    if currentGame.id ~= updatedGame.id then
        print("Updated game's ID != current game's ID, so not updating!")
        return false
    end
    return true
end

function M.doesAuthUserMatchGame(gameModel, authUser)
    if authUser.id ~= gameModel.player1 and authUser.id ~= gameModel.player2 then
        print("Error - incorrect authenticated user for game! User doesn't match either player.")
        print("Auth user = " .. json.encode(authUser))
        print("Player 1 = " .. json.encode(gameModel.player1Model))
        print("Player 2 = " .. json.encode(gameModel.player2Model))
        return false
    end
    return true
end

return M

