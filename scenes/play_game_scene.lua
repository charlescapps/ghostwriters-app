local composer = require("composer")
local widget = require("widget")
local json = require("json")
local native = require("native")
local game_ui = require("common.game_ui")
local game_helpers = require("common.game_helpers")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local current_game = require("globals.current_game")
local board_class = require("classes.board_class")
local rack_class = require("classes.rack_class")
local login_common = require("login.login_common")
local game_menu_class = require("classes.game_menu_class")
local new_game_data = require("globals.new_game_data")
local table = require("table")
local OneSignal = require("plugin.OneSignal")
local timer = require("timer")
local transition = require("transition")
local bonus_popup = require("classes.bonus_popup")
local grab_tiles_tip = require("tips.grab_tiles_tip")
local scry_tile_tip = require("tips.scry_tile_tip")
local question_tile_tip = require("tips.question_tile_tip")

local scene = composer.newScene()

-- Local helpers pre-declaration
local drawOptionsButton
local tilesToStr
local createGrabMoveJson
local getMoveDescription
local getBonusMoveDescription

scene.sceneName = "scenes.play_game_scene"

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view

    local gameModel = self:checkGameModelIsDefined()

    if not gameModel then
        return
    end

    self.creds = login_common.fetchCredentials()

    if not self.creds then
        return
    end

    if not game_helpers.doesAuthUserMatchGame(gameModel, self.creds.user) then
        return
    end

    local background = common_ui.createBackground()

    self.titleAreaDisplayGroup = self:createTitleAreaDisplayGroup(gameModel)

    self.board = self:createBoard(gameModel)

    self.rack = self:createRack(gameModel, self.board, self.creds.user)

    self.grabTilesTip = grab_tiles_tip.new(self)

    local isGameOver = game_helpers.isGameOver(gameModel)

    self.gameMenu = game_menu_class.new(self, display.contentWidth / 2, display.contentHeight / 2 - 50, isGameOver)

    self.actionButtonsGroup = self:createActionButtonsGroup(display.contentWidth + 175, 200, 80, self:getOnReleasePlayButton(), self:getOnReleaseResetButton(), self:getOnReleasePassButton())

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
    local boardCenterY = display.contentWidth / 2 + 160

    return board_class.new(gameModel, boardCenterX, boardCenterY, boardWidth, 20, self:getOnGrabTiles())
end

function scene:createRack(gameModel, board, authUser)
    local skipHint = gameModel and gameModel.moveNum and gameModel.moveNum > 2
    return rack_class.new(self, gameModel, 100, display.contentWidth + 274, 7, 25, board, authUser, skipHint)
end

-- "scene:show()"
function scene:show(event)
    local phase = event.phase

    if phase == "will" then
        print("play_game_scene:show() - phase = will")
        -- Called when the scene is still off screen (but is about to come on screen).
        if not self.creds then
            return
        end

        -- Disable action buttons if the game is finished.
        local gameModel = current_game.currentGame
        if gameModel and gameModel.gameResult ~= common_api.IN_PROGRESS and gameModel.gameResult ~= common_api.OFFERED then
           print("Disabling game with gameResult = '" .. tostring(gameModel.gameResult) .. "'")
           self:disableActionButtons()
        end

    elseif phase == "did" then
        print("play_game_scene:show() - phase = did")

        if not self.creds then
            login_common.logout()
            return
        end

        OneSignal.RegisterForNotifications()

        if self.board and self.board.gameModel and self.board.gameModel.lastMoves then
            self.movesToDisplay = table.copy(self.board.gameModel.lastMoves)
            self:applyOpponentMoves(nil, true)
        end

        -- Called when the scene is now on screen.
        self:showGameInfoModals(true)

        self:startPollForGame()

        local didShowModal = self.grabTilesTip:triggerTipOnCondition()

        if not didShowModal then
           didShowModal = scry_tile_tip.new(self):triggerTipOnCondition() or didShowModal
        end

        if not didShowModal then
           didShowModal = question_tile_tip.new(self):triggerTipOnCondition() or didShowModal
        end
    end
end

function scene:showGameInfoModals(didSceneJustLoad)
    local didShowModal = self:showGameOverModal()
    if didShowModal then
        return
    end

    if not didSceneJustLoad then
        didShowModal = self:showContinueTurnModal()
    end
end

function scene:getPollForGameListener()
    return function()
        if not self.creds then
            print("Error - trying to poll for game when self.creds == nil")
            return
        end
        if current_game.isUsersTurn(self.creds.user) then
            print("Not polling for game since it's the auth user's turn.")
            return
        end
        local currentGame = current_game.currentGame
        if currentGame and currentGame.gameResult and
                currentGame.gameResult ~= common_api.IN_PROGRESS and currentGame.gameResult ~= common_api.OFFERED then
           print("Not polling for game since game result is: " .. currentGame.gameResult)
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
        self:cancelPollForGame()
        transition.cancel()
    elseif (phase == "did") then
        print("play_game_scene:hide() - phase = did")
        -- Set self.view to nil, so that create() will be called each time we load this scene.
        self.view = nil
        composer.removeScene(self.sceneName, false)
        if self.grabTilesTip then
            self.grabTilesTip:stopTip()
        end
    end
end


-- "scene:destroy()"
function scene:destroy(event)
    print("play_game_scene:destroy()")
    -- Set self.view to nil, so that create() will be called each time we load this scene.
    self.view = nil
    self.creds = nil
    self.board, self.rack, self.gameMenu, self.titleAreaDisplayGroup, self.actionButtonsGroup, self.playMoveButton, self.resetButton, self.passButton =
        nil, nil, nil, nil, nil, nil, nil, nil

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

function scene:createTitleAreaDisplayGroup(gameModel)
    -- Option to start a rematch only present if game isn't IN_PROGRESS or OFFERED.
    local isAllowStartNewGame = gameModel.gameResult ~= common_api.IN_PROGRESS
            and gameModel.gameResult ~= common_api.OFFERED

    if not self.creds or not self.creds.user then
        return
    end

    local authUser = self.creds.user

    return game_ui.createVersusDisplayGroup(gameModel, authUser, self, true, nil, nil, nil, 75, nil, nil, isAllowStartNewGame)
end

function scene:createActionButtonsGroup(startY, width, height, onPlayButtonRelease, onResetButtonRelease, onPassButtonRelease)
    local group = display.newGroup()

    -- Create the Play Word button
    local y = startY + height / 2
    self.playMoveButton = widget.newButton {
        x = display.contentWidth / 2,
        y = y,
        emboss = true,
        label = "Play word",
        font = native.systemFont,
        fontSize = 36,
        width = width,
        height = height,
        shape = "roundedRect",
        cornerRadius = 15,
        labelColor = { default = common_ui.BUTTON_LABEL_COLOR_DEFAULT, over = common_ui.BUTTON_LABEL_COLOR_OVER },
        fillColor = { default = common_ui.BUTTON_FILL_COLOR_DEFAULT, over = common_ui.BUTTON_FILL_COLOR_OVER },
        strokeColor = { default = common_ui.BUTTON_STROKE_COLOR_DEFAULT, over = common_ui.BUTTON_STROKE_COLOR_OVER },
        strokeWidth = 2,
        onRelease = onPlayButtonRelease
    }

    -- Create the Pass button
    self.passButton = widget.newButton {
        x = display.contentWidth / 2 - width - 20,
        y = y,
        width = height,
        height = height,
        defaultFile = "images/pass_button_default.png",
        overFile = "images/pass_button_over.png",
        onRelease = onPassButtonRelease
    }

    -- Create the Reset button
    self.resetButton = widget.newButton {
        x = display.contentWidth / 2 + width + 20,
        y = y,
        width = height,
        height = height,
        defaultFile = "images/reset_button_default.png",
        overFile = "images/reset_button_over.png",
        onRelease = onResetButtonRelease
    }

    group:insert(self.playMoveButton)
    group:insert(self.resetButton)
    group:insert(self.passButton)
    return group
end

drawOptionsButton = function(x, y, width)
    return widget.newButton({
        x = x,
        y = y,
        width = width,
        height = width,
        defaultFile = "images/question_button_default.png",
        overFile = "images/question_button_over.png",
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
    print("Resetting scene...")

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
        return "grabbed \"" .. moveJson.letters .. "\"!"
    elseif moveJson.moveType == common_api.PLAY_TILES then
        return "played \"" .. moveJson.letters .. "\" for " .. moveJson.points .. " points!"
    elseif moveJson.moveType == common_api.PASS then
        return "passed."
    elseif moveJson.moveType == common_api.RESIGN then
        return "resigned."
    end
end

getBonusMoveDescription = function(move)
    local dict = move.dict
    if not dict then
        return getMoveDescription(move)
    end

    local dictName = common_api.getDictName(dict)
    local bonusPoints = common_api.getBonusPoints(dict)

    return "played a bonus word from the " .. dictName .. " dictionary for " .. bonusPoints .. " extra points!\n" ..
            "Total is " .. move.points .. " points"
end

function scene:resetBoardAndShowModals()
    self:reset()
    self:showGameInfoModals(false)
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

function scene:applyOpponentMoves(onApplyMovesComplete, skipResetBoard)
    if not self:didOpponentPlayMove(self.movesToDisplay) then
        print("Calling applyOpponentsMove. Creating a new board. Moves: " .. json.encode(self.movesToDisplay))
        self.movesToDisplay = nil
        self:fadeToTurn(false)
        if not skipResetBoard then
            self:resetBoardAndShowModals()
        end
        if onApplyMovesComplete then
            onApplyMovesComplete()
        end
        self:resumePollForGame()
        return
    end

    print("Calling applyOpponentsMove. Applying the last move: " .. json.encode(self.movesToDisplay))

    local firstMove = table.remove(self.movesToDisplay, 1)
    self:showMoveModal(firstMove, current_game.currentGame, function()
        if self.board then
            self.board:applyMove(firstMove, self.rack, firstMove.playerId == self.creds.user.id, function()
                self:applyOpponentMoves(onApplyMovesComplete, skipResetBoard)
            end)
        end
    end)
end

function scene:getOnSendMoveSuccess()
    return function(updatedGameModel)
        local myMove = updatedGameModel.myMove

        if myMove then
            -- if self.myMove is set, then apply my move, before applying opponent's moves (if present)
            print("Applying my move...")
            self:showMoveModal(myMove, updatedGameModel, function()
                self.board:applyMove(myMove, self.rack, true, function()
                    self.myMove = nil
                    local currentScene = composer.getSceneName("current")
                    if currentScene == self.sceneName then
                        print("Finished applying myMove, now applying opponent's move(s)...")
                        self:applyUpdatedGame(updatedGameModel, true)
                    end
                end)
            end)
        else
            print("Applying opponent's move(s) only...")
            self:applyUpdatedGame(updatedGameModel, false)
        end
    end
end

function scene:showMoveModal(move, game, onModalClose)
    if move.dict then
        print("Found special dict on move: " .. tostring(move.dict) .. ", showing bonus modal")
        self:showBonusMoveModal(move, onModalClose)
    else
        print("Found no special dict on move, showing ordinary modal. Dict was: " .. tostring(move.dict))
        self:showNormalMoveModal(move, game, onModalClose)
    end
end

function scene:showNormalMoveModal(move, game, onModalClose)
    if not self.creds or not self.creds.user then
        print "Errror - creds not defined in play_game_scene."
        return
    end
    local moveDescr = getMoveDescription(move)
    local moveUsername
    if move.playerId == self.creds.user.id then
        moveUsername = "You"
    elseif move.playerId == game.player1 then
        moveUsername = game.player1Model.username
    else
        moveUsername = game.player2Model.username
    end

    common_ui.createInfoModal(moveUsername, moveDescr, onModalClose)
end

function scene:showBonusMoveModal(move, onModalClose)
    if not self.creds or not self.creds.user then
        print "Error - creds not defined in play_game_scene."
        return
    end
    local dict = move.dict
    if not dict then
        return
    end

    local isCurrentPlayer = move.playerId == self.creds.user.id

    local bonusPopup = bonus_popup.new(dict, move.letters, isCurrentPlayer, onModalClose)
    bonusPopup:render()
    self.view:insert(bonusPopup.view)

    bonusPopup:show()
end

function scene:getOnRefreshGameSuccess()
    return function(updatedGameModel)
        self:applyUpdatedGame(updatedGameModel, false)
    end
end

function scene:applyUpdatedGame(updatedGameModel, isAfterPlayMove)

    if not game_helpers.isValidGameUpdate(current_game.currentGame, updatedGameModel) then
        print("Updated game isn't a valid game update. Returning from play_game_scene:applyUpdatedGame()...")
        self:resumePollForGame()
        return
    end

    print("Applying updated game...")
    current_game.currentGame = updatedGameModel

    if not isAfterPlayMove then
        print("Cancelling current grab.")
        self.board:cancelGrab()
        print("Returning tiles.")
        self.rack:returnAllTiles()
    end

    self.movesToDisplay = table.copy(updatedGameModel.lastMoves)
    print("Applying opponent move(s): " .. json.encode(self.movesToDisplay))
    self:applyOpponentMoves()
end

function scene:refreshGameFromServer()

    local currentGame = current_game.currentGame
    if not game_helpers.isValidGame(currentGame) then
        print("current_game.currentGame is invalid, cannot refresh from server.")
        return
    end

    self:pausePollForGame()
    common_api.getGameById(currentGame.id, true, currentGame.moveNum, self:getOnRefreshGameSuccess(), self:getRefreshGameFail(), self:getRefreshGameFail(), false)
end


function scene:fadeToTurn(isOpponentTurn)
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
        self:resumePollForGame()
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
                        if self.grabTilesTip then
                            self.grabTilesTip:stopTip()
                        end
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

function scene:getOnReleasePassButton()
    return function(event)
        self:showPassModal()
    end
end

function scene:disableActionButtons()
    self.playMoveButton:setEnabled(false)
    self.playMoveButton:setFillColor(0.6, 0.6, 0.6)
    self.resetButton:setEnabled(false)
    self.resetButton:setFillColor(0.6, 0.6, 0.6)
    self.passButton:setEnabled(false)
    self.passButton:setFillColor(0.6, 0.6, 0.6)
end

function scene:showGameOverModal()
    local gameModel = current_game.currentGame
    if not gameModel or gameModel.gameResult == common_api.IN_PROGRESS or gameModel.gameResult == common_api.OFFERED then
        print("Not displaying Game Over modal, game result is " .. tostring(gameModel and gameModel.gameResult))
        return false
    end

    if not self.creds or not self.creds.user then
        print("Not displaying Game Over modal, scene.creds is not defined")
        return false
    end

    self:disableActionButtons()

    local gameResult = gameModel.gameResult

    local authUser = self.creds.user

    local isMyWin = (gameResult == common_api.PLAYER1_WIN or gameResult == common_api.PLAYER2_RESIGN) and authUser.id == gameModel.player1 or
                    (gameResult == common_api.PLAYER2_WIN or gameResult == common_api.PLAYER1_RESIGN) and authUser.id == gameModel.player2

    local modalMessage
    if gameResult == common_api.PLAYER1_WIN then
        modalMessage = isMyWin and "You win!" or gameModel.player1Model.username .. " wins!"
    elseif gameResult == common_api.PLAYER2_WIN then
        modalMessage = isMyWin and "You win!" or gameModel.player2Model.username .. " wins!"
    elseif gameResult == common_api.PLAYER1_TIMEOUT then
        modalMessage = gameModel.player1Model.username .. " timed out."
    elseif gameResult == common_api.PLAYER2_TIMEOUT then
        modalMessage = gameModel.player2Model.username .. " timed out."
    elseif gameResult == common_api.PLAYER1_RESIGN then
        modalMessage = isMyWin and gameModel.player1Model.username .. " resigned." or "You resigned."
    elseif gameResult == common_api.PLAYER2_RESIGN then
        modalMessage = isMyWin and gameModel.player2Model.username .. " resigned." or "You resigned."
    elseif gameResult == common_api.REJECTED then
        modalMessage = self.creds and self.creds.user and self.creds.user.id == gameModel.player1 and "Your challenge was rejected. Try again!"
            or "You rejected this challenge."
    else
        print("Invalid game result: " .. tostring(gameResult))
        return false
    end

    local modal = common_ui.createInfoModal("Game Over", modalMessage, function() self:showRatingChangeModal() end)
    self.view:insert(modal)
    return true
end

function scene:showRatingChangeModal()
    local gameModel = current_game.currentGame
    if not gameModel then
        print("Error - attempt to call showRatingChangeModal but current_game.currentGame isn't defined.")
        return
    end
    if not self.creds or not self.creds.user then
        print("Error - attempt to call showRatingChangeModal but scene.creds.user isn't defined.")
        return
    end
    local authUser = self.creds.user
    local updatedRating = authUser.id == gameModel.player1 and gameModel.player1Model.rating or
                          gameModel.player2Model.rating

    local ratingIncrease = authUser.id == gameModel.player1 and gameModel.player1RatingIncrease or
                           authUser.id == gameModel.player2 and gameModel.player2RatingIncrease

    if not ratingIncrease or ratingIncrease <= 0 then
        print("In showRatingChangeModal, we must be viewing an old game, because the rating increase = " .. tostring(ratingIncrease))
        return
    end

    local modal = game_ui.createRatingUpModal(self, ratingIncrease)
    self.view:insert(modal)
end

function scene:showContinueTurnModal()
    local gameModel = current_game.currentGame
    if not gameModel or gameModel.gameResult ~= common_api.IN_PROGRESS then
        print("Not displaying Continue Turn modal, game result is " .. tostring(gameModel and gameModel.gameResult))
        return false
    end

    if not self.creds or not game_helpers.isPlayerTurn(gameModel, self.creds.user) then
        return false
    end

    local opponentRack = game_helpers.getNotCurrentPlayerRack(gameModel)

    if opponentRack == nil or opponentRack:len() > 0 then
        print("Not showing Continue Turn modal since opponent's rack isn't empty or it's nil")
        return false
    end

    if gameModel.lastMoves == nil or #gameModel.lastMoves > 0 then
        print("Not showing Continue Turn modal since opponent's lastMoves are present or nil")
        return false
    end

    local modal = common_ui.createInfoModal("Keep playing", "Your opponent is out of tiles!")
    self.view:insert(modal)

    return true
end

function scene:pass()
    local passMove = common_api.getPassMove(current_game.currentGame, self.creds.user.id)
    self.myMove = passMove
    common_api.sendMove(passMove, self:getOnSendMoveSuccess(), self:getOnSendMoveFail(), self:getOnSendMoveNetworkFail(), true)
end

function scene:resign()
    local resignMove = common_api.getResignMove(current_game.currentGame, self.creds.user.id)
    self.myMove = resignMove
    common_api.sendMove(resignMove, self:getOnSendMoveSuccess(), self:getOnSendMoveFail(), self:getOnSendMoveNetworkFail(), true)
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
        composer.setVariable(game_helpers.START_GAME_FROM_SCENE_KEY, self.sceneName)
        composer.gotoScene("scenes.choose_board_size_scene", "fade")
    end
end

function scene:isValidGameScene()
    return self.view and self.board and self.rack and self.creds and true
end

function scene:startPollForGame()
    if current_game.currentGame and current_game.currentGame.gameType == common_api.TWO_PLAYER then
        print("Starting poll for gameType=" .. current_game.currentGame.gameType)
        self.pollForGameHandle = timer.performWithDelay(30000, self:getPollForGameListener(), -1)
    end
end

function scene:resumePollForGame()
    if self.pollForGameHandle then
        print("Resuming poll for game timer...")
        timer.resume(self.pollForGameHandle)
    end
end

function scene:pausePollForGame()
    if self.pollForGameHandle then
        print("Pausing poll for game timer...")
        timer.pause(self.pollForGameHandle)
    end
end

function scene:cancelPollForGame()
    if self.pollForGameHandle then
        print("Cancelling poll for game timer...")
        timer.cancel(self.pollForGameHandle)
        self.pollForGameHandle = nil
    end
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-- -------------------------------------------------------------------------------

return scene

