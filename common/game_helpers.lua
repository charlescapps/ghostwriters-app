local json = require("json")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local current_game = require("globals.current_game")
local new_game_data = require("globals.new_game_data")
local composer = require("composer")
local native = require("native")
local transition = require("transition")

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
    new_game_data.clearAll()
    new_game_data.isAcceptGame = true
    new_game_data.gameId = gameId
    new_game_data.boardSize = boardSize
    new_game_data.specialDict = specialDict
    new_game_data.gameDensity = gameDensity
    new_game_data.bonusesType = bonusesType
    composer.gotoScene("scenes.accept_game_scene", { effect = "fade" })
end

function M.promptScryTileAction(board, rack, tileImage)

    local function alertListener(event)
        if event.action == "clicked" then
            local i = event.index
            if i == 1 then
                M.executeScryTileAction(board, rack, tileImage)
            elseif i == 2 then
                rack:returnTileImage(tileImage, nil)
            end
        end
    end

    native.showAlert("Special Action", "Use Scry tile to find a powerful move?", { "Yes", "No" }, alertListener)

end

function M.executeScryTileAction(board, rack, tileImage)
    local gameModel = board.gameModel

    local function onSuccess(move)
        print("Received scry move back from server.")
        if not M.isValidMove(move) then
            print("ERROR - empty move received from scry tile action.")
            rack:returnTileImage(tileImage, nil)
            return
        end
        rack:removeTileImage(tileImage)
        common_ui.fadeOutThenRemove(tileImage)
        M.stageMove(board, rack, move)
    end

    local function onFail()
        print("FAIL to get scry move from server.")
        native.showAlert("Error", "A network error occurred. Try again soon.", {"OK"})
        rack:returnTileImage(tileImage, nil)
    end

    common_api.doScryTileAction(gameModel.id, onSuccess, onFail, true)
end

function M.stageMove(board, rack, move)
    local rStart = move.start.r + 1
    local cStart = move.start.c + 1
    local start = { rStart, cStart }

    local dirVec = M.dirToDirVector(move.dir)

    local tiles = move.tiles

    rack:returnAllTiles()

    for i = 0, tiles:len() - 1 do
        local pos = M.go(start, dirVec, i)
        local letter = tiles:sub(i + 1, i + 1)
        M.dragTileFromRackToBoard(board, rack, letter, pos)
    end

end

function M.dragTileFromRackToBoard(board, rack, letter, pos)
    local rackTile = rack:getFirstRackTileForLetter(letter)
    local square = board.squareImages[pos[1]][pos[2]]
    local squareContentX, squareContentY = square.parent:localToContent(square.x, square.y)

    local function onMoveComplete(obj)
        board:addTileFromRack(squareContentX, squareContentY, obj, rack)
    end

    rack:floatTile(rackTile)
    rack:removeTileImage(rackTile)

    transition.to(rackTile, { time = 2000, x = squareContentX, y = squareContentY, onComplete = onMoveComplete } )
end

function M.go(start, dirVec, num)
    return { start[1] + dirVec[1] * num, start[2] + dirVec[2] * num }
end

function M.dirToDirVector(dir)
    return dir == "E" and { 0, 1 } or { 1, 0 }
end

function M.isValidMove(move)
    return move and move.start and move.start.r and move.start.c and move.gameId and move.letters and move.tiles and move.dir and true
end

return M