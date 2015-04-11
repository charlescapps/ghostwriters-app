local composer = require("composer")
local widget = require("widget")
local json = require("json")
local game_ui = require("common.game_ui")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local current_game = require("globals.current_game")
local board_class = require("classes.board_class")
local rack_class = require("classes.rack_class")
local login_common = require("login.login_common")
local game_menu_class = require("classes.game_menu_class")
local new_game_data = require("globals.new_game_data")
local table = require("table")
local GameThrive = require("plugin.GameThrivePushNotifications")
local timer = require("timer")
local scene = composer.newScene()

-- Local helpers pre-declaration
local drawOptionsButton
local tilesToStr
local createGrabMoveJson
local getMoveDescription

scene.sceneName = "scenes.play_game_scene"

-- "scene:create()"
function scene:create(event)
    self.isDestroyed = nil
    local sceneGroup = self.view

    local gameModel = self:checkGameModelIsDefined()

    if not gameModel then
        return
    end

    self.creds = login_common.fetchCredentialsOrLogout(self.sceneName)

    if not self.creds then
        return
    end

    if not self:doesAuthUserMatchGame(gameModel, self.creds.user) then
        return
    end

    local background = common_ui.createBackground()

    self.titleAreaDisplayGroup = self:createTitleAreaDisplayGroup(gameModel)

    self.board = self:createBoard(gameModel)

    self.rack = self:createRack(gameModel, self.board, self.creds.user)

    self.gameMenu = game_menu_class.new(display.contentWidth / 2, display.contentHeight / 2 - 50, function()
        self.gameMenu:close()
        self:showPassModal()
    end)

    self.actionButtonsGroup = self:createActionButtonsGroup(display.contentWidth + 195, 200, 64, self:getOnReleasePlayButton(), self:getOnReleaseResetButton())

    self.optionsButton = drawOptionsButton(display.contentWidth - 75, display.contentHeight - 60, 90)

    sceneGroup:insert(background)
    sceneGroup:insert(self.titleAreaDisplayGroup)

    sceneGroup:insert(self.board.boardContainer)
    sceneGroup:insert(self.rack.displayGroup)
    sceneGroup:insert(self.optionsButton)
    sceneGroup:insert(self.actionButtonsGroup)
    sceneGroup:insert(self.gameMenu.displayGroup)
end

function scene:createBoard(gameModel)
    local boardWidth = display.contentWidth - 20
    local boardCenterX = display.contentWidth / 2
    local boardCenterY = display.contentWidth / 2 + 180

    return board_class.new(gameModel, boardCenterX, boardCenterY, boardWidth, 20, self:getOnGrabTiles())
end

function scene:createRack(gameModel, board, authUser)
    return rack_class.new(gameModel, 100, display.contentWidth + 274, 7, 25, board, authUser)
end

-- "scene:show()"
function scene:show(event)
    local phase = event.phase

    if self.isDestroyed then
        print("Error - play_game_scene is destroyed in scene:show(). Phase = " .. phase)
        return
    end

    if (phase == "will") then
        print("play_game_scene:show() - phase = will")
        -- Called when the scene is still off screen (but is about to come on screen).
        self.creds = login_common.fetchCredentialsOrLogout(self.sceneName) -- Check if the current user is logged in.
        if not self.creds then
            print("Error - user didn't have credentials on play_game_scene:show(). Logging out...")
            return
        end

    elseif (phase == "did") then
        print("play_game_scene:show() - phase = did")
        GameThrive.RegisterForNotifications()

        if self.board and self.board.gameModel and self.board.gameModel.lastMoves then
            self.movesToDisplay = table.copy(self.board.gameModel.lastMoves)
            self:applyOpponentMoves(function()
                self:showGameOverModal()
                self:showNoMovesModal()
            end)
        else
            -- Called when the scene is now on screen.
            self:showGameOverModal()
            self:showNoMovesModal()
        end

        self.pollForGameHandle = timer.performWithDelay(30000, self:getPollForGameListener(), -1)
    end
end

function scene:getPollForGameListener()
    return function()
        if self.isDestroyed then
            print("Error - trying to poll for game when isDestroyed == true")
            return
        end
        if not self.creds then
            print("Error - trying to poll for game when self.creds == nil")
            return
        end
        if current_game.isUsersTurn(self.creds.user) then
            print("Not polling for game since it's the auth user's turn.")
            return
        end
        self:refreshGameFromServer()
    end
end


-- "scene:hide()"
function scene:hide(event)
    local phase = event.phase

    if (phase == "will") then
        print("play_game_scene:hide() - phase = will")
        if self.pollForGameHandle then
            timer.cancel(self.pollForGameHandle)
            self.pollForGameHandle = nil
        end
    elseif (phase == "did") then
        print("play_game_scene:hide() - phase = did")
        -- Set self.view to nil, so that create() will be called each time we load this scene.
        self.view = nil
    end
end


-- "scene:destroy()"
function scene:destroy(event)
    print("play_game_scene:destroy()")
    -- Set self.view to nil, so that create() will be called each time we load this scene.
    self.view = nil
    self.isDestroyed = true
    self.creds = nil
    self.board, self.rack, self.gameMenu, self.titleAreaDisplayGroup, self.actionButtonsGroup, self.playMoveButton, self.resetButton = nil, nil, nil, nil, nil, nil, nil

end

-- Local helpers
function scene:checkGameModelIsDefined()
    local gameModel = current_game.currentGame

    if not gameModel then
        print("Error - no current game is defined in the current_game module.")
        local currentScene = composer.getSceneName("current")
        if currentScene == self.sceneName then
            composer.gotoScene("scenes.title_scene")
            composer.removeScene(currentScene, false)
        end
    end

    return gameModel
end

function scene:doesAuthUserMatchGame(gameModel, authUser)
    if authUser.id ~= gameModel.player1 and authUser.id ~= gameModel.player2 then
        print("Error - incorrect authenticated user for game! User doesn't match either player.")
        print("Auth user = " .. json.encode(authUser))
        print("Player 1 = " .. json.encode(gameModel.player1Model))
        print("Player 2 = " .. json.encode(gameModel.player2Model))
        return false
    end
    return true
end

function scene:createTitleAreaDisplayGroup(gameModel)
    local isAllowStartNewGame = gameModel.gameResult ~= common_api.IN_PROGRESS
    return game_ui.createVersusDisplayGroup(gameModel, self.creds.user, self, false, nil, nil, nil, 100, nil, nil, isAllowStartNewGame)
end

function scene:createActionButtonsGroup(startY, width, height, onPlayButtonRelease, onResetButtonRelease)
    local group = display.newGroup()
    -- Create the Play Word button
    local x1 = display.contentWidth / 2 - width / 2 - 5
    local y = startY + height / 2
    self.playMoveButton = widget.newButton {
        x = x1,
        y = y,
        emboss = true,
        label = "Play word",
        fontSize = 32,
        labelColor = { default = { 1, 0.9, 0.9 }, over = { 0, 0, 0 } },
        width = width,
        height = height,
        shape = "roundedRect",
        cornerRadius = 15,
        fillColor = { default = { 0.93, 0.48, 0.01, 0.7 }, over = { 0.76, 0, 0.13, 1 } },
        strokeColor = { 1, 0.2, 0.2 },
        strokeRadius = 10,
        onRelease = onPlayButtonRelease
    }

    -- Create the Reset button
    local x2 = display.contentWidth / 2 + width / 2 + 5
    self.resetButton = widget.newButton {
        x = x2,
        y = y,
        emboss = true,
        label = "Reset",
        fontSize = 32,
        labelColor = { default = { 1, 0.9, 0.9 }, over = { 0, 0, 0 } },
        width = width,
        height = height,
        shape = "roundedRect",
        cornerRadius = 15,
        fillColor = { default = { 0.93, 0.48, 0.01, 0.7 }, over = { 0.76, 0, 0.13, 1 } },
        strokeColor = { 1, 0.2, 0.2 },
        strokeRadius = 10,
        onEvent = onResetButtonRelease
    }

    group:insert(self.playMoveButton)
    group:insert(self.resetButton)
    return group
end

drawOptionsButton = function(x, y, width)
    return widget.newButton({
        x = x,
        y = y,
        width = width,
        height = width,
        defaultFile = "images/options-button.png",
        overFile = "images/options-button-pressed.png",
        onPress = nil,
        onRelease = scene:getOnReleaseOptionsButton()
    })
end

function scene:getOnReleaseOptionsButton()
    return function(event)
        print("Options button pressed!")
        self.gameMenu:toggle()
    end
end

tilesToStr = function(tiles, sep)
    local str = ""
    for i = 1, #tiles do
        local t = tiles[i]
        if i == 1 then
            str = str .. t.letter:upper()
        else
            str = str .. sep .. t.letter:upper()
        end
    end
    return str
end

createGrabMoveJson = function(tiles)
    local gameModel = current_game.currentGame
    local letters = tilesToStr(tiles, "")
    local dir
    if #tiles == 1 then
        dir = "E" -- direction doesn't matter for a single tile grab.
    elseif tiles[1].row == tiles[2].row then
        if tiles[2].col > tiles[1].col then
            dir = "E"
        else
            dir = "W"
        end
    else
        if tiles[2].row > tiles[1].row then
            dir = "S"
        else
            dir = "N"
        end
    end
    return {
        gameId = gameModel.id,
        letters = letters,
        tiles = letters,
        moveType = common_api.GRAB_TILES,
        start = { r = tiles[1].row - 1, c = tiles[1].col - 1 },
        dir = dir
    }
end

function scene:reset()
    if self.isDestroyed then
        print("Error - play_game_scene is destroyed in scene:reset().")
        return
    end

    local gameModel = current_game.currentGame
    if not gameModel then
        print("Error - current_game.currentGame wasn't defined when reset() was called in single player scene")
        local currentScene = composer.getSceneName("current")
        if currentScene == self.sceneName then
            composer.gotoScene("scenes.title_scene")
            composer.removeScene(currentScene, false)
        end
        return
    end

    local oldTitleArea = self.titleAreaDisplayGroup
    local oldBoard = self.board
    local oldRack = self.rack

    self.titleAreaDisplayGroup = scene:createTitleAreaDisplayGroup(gameModel)

    self.board = self:createBoard(gameModel)
    self.rack = self:createRack(gameModel, self.board, self.creds.user)

    local viewGroup = self.view
    viewGroup:insert(self.board.boardContainer)
    viewGroup:insert(self.rack.displayGroup)
    viewGroup:insert(self.titleAreaDisplayGroup)

    self.optionsButton:toFront() -- Put the options button on top of the new rack.
    self.gameMenu.displayGroup:toFront() -- Put the game menu in front

    oldBoard:destroy()
    oldRack:destroy()
    oldTitleArea:removeSelf()
end

getMoveDescription = function(moveJson)
    if moveJson.moveType == common_api.GRAB_TILES then
        return "grabbed the tiles \"" .. moveJson.letters .. "\"!"
    elseif moveJson.moveType == common_api.PLAY_TILES then
        return "played \"" .. moveJson.letters .. "\" for " .. moveJson.points .. " points!"
    elseif moveJson.moveType == common_api.PASS then
        return "passed."
    end
end

function scene:resetBoardAndShowModals()
    self:reset()
    self:showGameOverModal()
end

function scene:getOpponentUser()
    local gameModel = self.board.gameModel
    local authUser = self.creds.user
    if gameModel.player1 == authUser.id then
        return gameModel.player2Model
    else
        return gameModel.player1Model
    end
end

function scene:didOpponentPlayMove(lastMoves)
    return lastMoves and #lastMoves > 0 and lastMoves[1].playerId ~= self.creds.user.id
end

function scene:applyOpponentMoves(onApplyMovesComplete)
    if not self:didOpponentPlayMove(self.movesToDisplay) then
        print("Calling applyOpponentsMove. Creating a new board Moves: " .. json.encode(self.movesToDisplay))
        self.movesToDisplay = nil
        self:fadeToTurn(false)
        self:resetBoardAndShowModals()
        if onApplyMovesComplete then
            onApplyMovesComplete()
        end
        if self.pollForGameHandle then
            timer.resume(self.pollForGameHandle)
        end
        return
    end

    print("Calling applyOpponentsMove. Applying the last move: " .. json.encode(self.movesToDisplay))

    local firstMove = table.remove(self.movesToDisplay, 1)
    local moveDescr = getMoveDescription(firstMove)
    local opponent = self:getOpponentUser()
    common_ui.createInfoModal(opponent.username, moveDescr, function()
        if self.board then
            self.board:applyMove(firstMove, self.rack, firstMove.playerId == self.creds.user.id, function()
                self:applyOpponentMoves()
            end)
        end
    end)
end

function scene:getOnSendMoveSuccess()
    return function(updatedGameModel)
        self:applyUpdatedGame(updatedGameModel)
    end
end

function scene:applyUpdatedGame(updatedGameModel)
    print("Applying updated game...")
    current_game.currentGame = updatedGameModel

    local myMove = self.myMove

    if myMove then
        print("Applying myMove...")
        -- if self.myMove is set, then apply my move, before applying opponent's moves (if present)
        local moveDescr = getMoveDescription(myMove)

        common_ui.createInfoModal("You", moveDescr, function()
            self.board:applyMove(myMove, self.rack, true, function()
                self.myMove = nil
                local currentScene = composer.getSceneName("current")
                if currentScene == self.sceneName then
                    print("Finished applying myMove, now applying opponent's move(s)...")
                    self.movesToDisplay = table.copy(updatedGameModel.lastMoves)

                    if self:didOpponentPlayMove(self.movesToDisplay) then
                        self:fadeToTurn(true)
                    end

                    print("Calling applyOpponentsMove from onSendMoveSuccess. Moves: " .. json.encode(self.movesToDisplay))
                    self:applyOpponentMoves()
                end
            end)
        end)
    else
        print("Applying opponent's move(s) only...")
    -- If self.myMove is not present, just cancel whatever you've done on the board, then apply the opponent's moves.
        self.board:cancelGrab()
        self.rack:returnAllTiles()
        self.movesToDisplay = table.copy(updatedGameModel.lastMoves)
        print("Calling applyOpponentsMove from onSendMoveSuccess. Moves: " .. json.encode(self.movesToDisplay))
        self:applyOpponentMoves()
    end
end

function scene:refreshGameFromServer()
    if self.pollForGameHandle then
       timer.pause(self.pollForGameHandle)
    end
    local currentGame = current_game.currentGame
    if not currentGame or not currentGame.id then
        print("current_game.currentGame is invalid, cannot refresh from server:" .. json.encode(currentGame))
        if self.pollForGameHandle then
            timer.resume(self.pollForGameHandle)
        end
        return
    end

    common_api.getGameById(currentGame.id, true, self:getOnSendMoveSuccess(), self:getRefreshGameFail(), self:getRefreshGameFail(), false)
end


function scene:fadeToTurn(isOpponentTurn)
    if self.isDestroyed then
        return
    end
    if isOpponentTurn then
        transition.fadeOut(self.titleAreaDisplayGroup.leftCircle, { time = 2000 })
        transition.fadeIn(self.titleAreaDisplayGroup.rightCircle, { time = 2000 })
    else
        transition.fadeIn(self.titleAreaDisplayGroup.leftCircle, { time = 2000 })
        transition.fadeOut(self.titleAreaDisplayGroup.rightCircle, { time = 2000 })
    end
end


function scene:getOnSendMoveFail()
    return function(json)
        self.myMove = nil
        if json and json["errorMessage"] then
            local message
            local messageFromServer = json["errorMessage"]
            if messageFromServer and messageFromServer:len() > 0 then
                message = messageFromServer
            else
                message = "Invalid move!"
            end
            native.showAlert("Oops...", message, { "Try again" })
        else
            native.showAlert("Network error", "A network error occurred", { "Try again" })
        end
        self.rack:enableInteraction()
        self.board:enableInteraction()
        self.board:cancelGrab()
    end
end

function scene:getRefreshGameFail()
    return function(jsonResp)
        print("Error updating game:" .. json.encode(jsonResp))
    end
end

function scene:getOnSendMoveNetworkFail()
    return function(event)
        self.myMove = nil
        native.showAlert("Network Error", "Network error, please try again", { "OK" }, function(event)
            if event.action == "clicked" then
                self.rack:enableInteraction()
                self.board:enableInteraction()
            end
        end)
        self.board:cancelGrab()
    end
end

function scene:getOnGrabTiles()
    return function(tiles)
        print("Tiles grabbed!")
        if not current_game.isUsersTurn(self.creds.user) then
            common_ui.createInfoModal("Oops...", "It's not your turn")
            self.board:cancelGrab()
            return
        end

        local lettersStr = tilesToStr(tiles, ", ")

        native.showAlert("Grab tiles?", "Grab tiles: " .. lettersStr .. "?", { "OK", "Nope" },
            function(event)
                if event.action == "clicked" then
                    local i = event.index
                    if i == 1 then
                        self.rack:returnAllTiles()
                        self.board:disableInteraction()
                        self.rack:disableInteraction()
                        local moveJson = createGrabMoveJson(tiles)
                        self.myMove = moveJson
                        common_api.sendMove(moveJson, self:getOnSendMoveSuccess(), self:getOnSendMoveFail(), self:getOnSendMoveNetworkFail(), true)
                    elseif i == 2 then
                        self.board:cancelGrab()
                        -- Do nothing, user clicked "Nope"
                    end
                end
            end)
    end
end

function scene:getOnReleasePlayButton()
    return function(event)
        if not current_game.isUsersTurn(self.creds.user) then
            common_ui.createInfoModal("Oops...", "It's not your turn")
            return
        end

        local move = self.board:getCurrentPlayTilesMove()
        if move["errorMsg"] then
            native.showAlert("Oops...", move["errorMsg"], { "Try again" })
            return
        end
        local gameModel = current_game.currentGame
        if not gameModel then
            print("Error - no game model defined in current_game module when clicking Play button.")
            return
        end
        move.gameId = gameModel.id
        native.showAlert("Send move?", "Play word " .. move.letters .. " ?", { "Yes", "Nope" }, function(event)
            local index = event.index
            if index == 1 then
                -- Disable interaction until the move is complete
                print("Sending move: " .. json.encode(move))
                self.board:disableInteraction()
                self.rack:disableInteraction()
                self.myMove = move
                common_api.sendMove(move, self:getOnSendMoveSuccess(), self:getOnSendMoveFail(), self:getOnSendMoveNetworkFail(), true)
            else
                print("User clicked 'Nope'")
            end
        end)
    end
end

function scene:getOnReleaseResetButton()
    return function(event)
        self.rack:returnAllTiles()
    end
end

function scene:showGameOverModal()
    if self.isDestroyed then
        print("Error - isDestroyed by called play_game_scene:showGameOverModal()")
        return
    end

    local gameModel = current_game.currentGame
    if not gameModel or gameModel.gameResult == common_api.IN_PROGRESS then
        print("Not displaying Game Over modal, game result is " .. tostring(gameModel and gameModel.gameResult))
        return
    end

    self.playMoveButton:setEnabled(false)
    self.resetButton:setEnabled(false)

    local gameResult = gameModel.gameResult

    local modalMessage
    if gameResult == common_api.PLAYER1_WIN then
        modalMessage = gameModel.player1Model.username .. " wins!"
    elseif gameResult == common_api.PLAYER2_WIN then
        modalMessage = gameModel.player2Model.username .. " wins!"
    elseif gameResult == common_api.PLAYER1_TIMEOUT then
        modalMessage = gameModel.player1Model.username .. " timed out."
    elseif gameResult == common_api.PLAYER2_TIMEOUT then
        modalMessage = gameModel.player2Model.username .. " timed out."
    else
        print("Invalid game result: " .. tostring(gameResult))
        return
    end

    local modal = common_ui.createInfoModal("Game Over", modalMessage, nil, nil, nil)
    self.view:insert(modal)
end

function scene:showNoMovesModal()
    if self.isDestroyed then
        print("Error - isDestroyed by called play_game_scene:showNoMovesModal()")
        return
    end

    local gameModel = current_game.currentGame
    if not gameModel or gameModel.gameResult ~= common_api.IN_PROGRESS or not self.board then
        return
    end

    if gameModel.player1Rack:len() > 0 or gameModel.tiles:upper() ~= gameModel.tiles then
        return
    end

    local modalMessage = "You must pass.\nTouch to continue..."

    common_ui.createInfoModal("No Moves!", modalMessage, function() self:pass() end)
end

function scene:pass()
    local passMove = common_api.getPassMove(current_game.currentGame, self.creds.user.id)
    self.myMove = passMove
    common_api.sendMove(passMove, self:getOnSendMoveSuccess(), self:getOnSendMoveFail(), self:getOnSendMoveNetworkFail(), true)
end

function scene:showPassModal()
    native.showAlert("Pass?", "Are you sure you want to pass?", { "Yes", "Nope" }, function(event)
        if event.action == "clicked" then
            if event.index == 1 then
                self:pass()
            end
        end
    end)
end

function scene:startGameWithUser(userModel)
    local currentScene = composer.getSceneName("current")
    if currentScene == self.sceneName and userModel.id ~= self.creds.user.id then
        new_game_data.clearAll()
        new_game_data.rival = userModel
        new_game_data.gameType = common_api.TWO_PLAYER
        composer.gotoScene("scenes.choose_board_size_scene", "fade")
    end
end

function scene:isValidGameScene()
    return self.view and self.board and self.rack and self.creds and true
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-- -------------------------------------------------------------------------------

return scene

