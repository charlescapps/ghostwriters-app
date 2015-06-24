local json = require("json")
local common_api = require("common.common_api")
local current_game = require("globals.current_game")
local new_game_data = require("globals.new_game_data")
local composer = require("composer")

local M = {}

M.START_GAME_FROM_SCENE_KEY = "startGameFromScene"

function M.isPlayerTurn(gameModel, userModel)
    if not userModel or not userModel.id then
        print("ERROR - invalid user model passed into game_helpers.isPlayerTurn: " .. json.encode(userModel))
        return false
    end

    return gameModel.player1Turn and userModel.id == gameModel.player1 or
       not gameModel.player1Turn and userModel.id == gameModel.player2
end

function M.getCurrentPlayerRack(gameModel)
    return gameModel.player1Turn and gameModel.player1Rack or
           gameModel.player2Rack
end

function M.getNotCurrentPlayerRack(gameModel)
    return gameModel.player1Turn and gameModel.player2Rack or
           gameModel.player1Rack
end

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

function M.isGameOver(gameModel)
    if not gameModel or not gameModel.gameResult then
        print("ERROR - nil gameModel or gameModel.gameResult passed into game_helpers#isGameOver()")
        return false
    end
    return gameModel.gameResult ~= common_api.IN_PROGRESS and gameModel.gameResult ~= common_api.OFFERED
end

function M.goToAcceptGameScene(gameId, boardSize, specialDict, gameDensity, bonusesType)
    if not gameId then
        print("ERROR - no gameId in goToAcceptGameScene")
        return
    end
    new_game_data.isAcceptGame = true
    new_game_data.gameId = gameId
    new_game_data.boardSize = boardSize
    new_game_data.specialDict = specialDict
    new_game_data.gameDensity = gameDensity
    new_game_data.bonusesType = bonusesType
    composer.gotoScene("scenes.accept_game_scene", "fade")
end


return M

