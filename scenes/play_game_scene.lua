local composer = require("composer")
local display = require("display")
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
local free_question_tile_tip = require("tips.free_question_tile_tip")
local question_tile_tip = require("tips.question_tile_tip")
local zoom_in_tip = require("tips.zoom_in_tip")
local play_word_tip = require("tips.play_word_tip")
local end_game_tip = require("tips.end_game_tip")
local pass_tip = require("tips.pass_tip")
local back_to_main_menu_popup = require("classes.back_to_main_menu_popup")
local challenged_popup = require("classes.challenged_popup")
local back_button_setup = require("android.back_button_setup")
local fonts = require("globals.fonts")
local music = require("common.music")
local toast = require("classes.toast")
local network = require("network")
local one_signal_util = require("push.one_signal_util")

local scene = composer.newScene()

-- Local helpers pre-declaration
local tilesToStr
local createGrabMoveJson
local getMoveDescription
local getBonusMoveDescription

scene.sceneName = "scenes.play_game_scene"
scene.onBackButtonReturnToTitle = true

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
        self.creds = nil
        return
    end

    local background = common_ui.createBackground()

    self.titleAreaDisplayGroup = self:createTitleAreaDisplayGroup(gameModel)

    self.board = self:createBoard(gameModel)

    self.rack = self:createRack(gameModel, self.board, self.creds.user)

    self.grabTilesTip = grab_tiles_tip.new(self)

    local isGameOver = game_helpers.isGameOver(gameModel)

    self.gameMenu = game_menu_class.new(self, display.contentWidth / 2, display.contentHeight / 2 - 50, isGameOver)

    self.actionButtonsGroup = self:createActionButtonsForGameState()

    sceneGroup:insert(background)
    sceneGroup:insert(self.titleAreaDisplayGroup)

    if self.actionButtonsGroup then
        sceneGroup:insert(self.actionButtonsGroup)
    end

    sceneGroup:insert(self.board.boardContainer)
    sceneGroup:insert(self.gameMenu.displayGroup)
    sceneGroup:insert(self.rack.displayGroup)
end

function scene:createBoard(gameModel)
    local boardWidth = display.contentWidth - 20
    local boardCenterX = display.contentWidth / 2
    local boardCenterY = display.contentWidth / 2 + 160

    return board_class.new(gameModel, self.creds.user, boardCenterX, boardCenterY, boardWidth, 20, self:getOnGrabTiles())
end

function scene:createRack(gameModel, board, authUser)
    return rack_class.new(self, gameModel, 100, display.contentWidth + 274, 7, 25, board, authUser, self:getOnReleaseOptionsButton())
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

        music.playInGameMusic()

    elseif phase == "did" then
        print("play_game_scene:show() - phase = did")

        if not self.creds then
            login_common.logout()
            return
        end

        -- For iOS, ask player if they want push notifications now.
        OneSignal.RegisterForNotifications()

        -- Check if we have any pending attempts to send the player's OneSignal player ID to the Ghostwriters server.
        one_signal_util.updateOneSignalInfoFromQueue()

        -- Called when the scene is now on screen.
        local didShowModal = self:showGameInfoModals(true)

        if not didShowModal then
            self:showOpponentsLastMoves()
        end

        self:startPollForGame()

        back_button_setup.setBackListenerToReturnToTitleScene()
    end
end

function scene:showTips()
    if not self.grabTilesTip then
        return
    end

    local didShowModal = self.grabTilesTip:triggerTipOnCondition()

    if not didShowModal then
        didShowModal = free_question_tile_tip.new(self):triggerTipOnCondition() or didShowModal
    end

    if not didShowModal then
        didShowModal = play_word_tip.new(self):triggerTipOnCondition() or didShowModal
    end

    if not didShowModal then
        didShowModal = zoom_in_tip.new(self):triggerTipOnCondition() or didShowModal
    end

    if not didShowModal then
        didShowModal = pass_tip.new():triggerTipOnCondition() or didShowModal
    end

    if not didShowModal then
        didShowModal = end_game_tip.new():triggerTipOnCondition() or didShowModal
    end

    if not didShowModal then
        didShowModal = question_tile_tip.new(self):triggerTipOnCondition() or didShowModal
    end

    if not didShowModal then
        didShowModal = scry_tile_tip.new(self):triggerTipOnCondition() or didShowModal
    end

    return didShowModal
end

function scene:showOpponentsLastMoves()
    local lastMoves = self.board and self.board.gameModel and self.board.gameModel.lastMoves
    self:applyOpponentMoves(lastMoves, nil, true)
end

function scene:showGameInfoModals(didSceneJustLoad)
    local didShowModal = self:showGameOverModal()

    if not didShowModal then
        didShowModal = didShowModal or self:showTips()
    end

    return didShowModal
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
        local pendingRequest = self.requestId
        if pendingRequest then
            network.cancel(pendingRequest)
            self.requestId = nil
        end
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

    return game_ui.createVersusDisplayGroup(gameModel, authUser, self, true, nil, nil, nil, 75, nil, nil, false, isAllowStartNewGame)
end

function scene:createActionButtonsForGameState()
    local user = self.creds and self.creds.user

    if not user then
        print("ERROR - cannot find a valid authenticated user. Not creating action buttons!")
        return nil
    end

    local gameModel = current_game.currentGame
    if not gameModel then
        print("ERROR - gameModel not currently defined")
    end

    local START_Y = display.contentWidth + 175
    local BUTTON_WIDTH = 200
    local BUTTON_HEIGHT = 80

    -- if it's NOT my turn or it's the end of the game, then draw the different button set.
    if not current_game.isUsersTurn(user) or game_helpers.isGameOver(gameModel) then
        return self:createActionButtonsForNotMyTurn(START_Y, BUTTON_WIDTH, BUTTON_HEIGHT)
    else
        return self:createActionButtonsForMyTurn(START_Y, BUTTON_WIDTH, BUTTON_HEIGHT)
    end
end

function scene:createActionButtonsForNotMyTurn(startY, width, height)
    local group = display.newGroup()

    -- Create the My Games button
    local y = startY + height / 2
    local playMoveButton = widget.newButton {
        x = display.contentWidth / 2,
        y = y,
        emboss = true,
        label = "My Games",
        font = fonts.DEFAULT_FONT,
        fontSize = 36,
        width = width,
        height = height,
        shape = "roundedRect",
        cornerRadius = 15,
        labelColor = { default = common_ui.BUTTON_LABEL_COLOR_DEFAULT, over = common_ui.BUTTON_LABEL_COLOR_OVER },
        fillColor = { default = common_ui.BUTTON_FILL_COLOR_DEFAULT, over = common_ui.BUTTON_FILL_COLOR_OVER },
        strokeColor = { default = common_ui.BUTTON_STROKE_COLOR_DEFAULT, over = common_ui.BUTTON_STROKE_COLOR_OVER },
        strokeWidth = 2,
        onRelease = self:getOnReleaseMyGamesButton()
    }

    -- Create the Back button
    self.backButton = widget.newButton {
        x = display.contentWidth / 2 - width - 20,
        y = y,
        width = 100,
        height = 100,
        defaultFile = "images/back_button_default.png",
        overFile = "images/back_button_over.png",
        onRelease = back_button_setup.promptToReturnToMainMenu
    }

    -- Create the Dictionary button
    self.dictionaryButton = widget.newButton {
        x = display.contentWidth / 2 + width + 20,
        y = y,
        width = height,
        height = height,
        defaultFile = "images/dictionary_button_default.png",
        overFile = "images/dictionary_button_over.png",
        onRelease = self:getOnReleaseDictionaryButton()
    }

    group:insert(playMoveButton)
    group:insert(self.backButton)
    group:insert(self.dictionaryButton)
    return group
end

function scene:createActionButtonsForMyTurn(startY, width, height)
    local group = display.newGroup()

    -- Create the Play Word button
    local y = startY + height / 2
    self.playMoveButton = widget.newButton {
        x = display.contentWidth / 2,
        y = y,
        emboss = true,
        label = "Play word",
        font = fonts.DEFAULT_FONT,
        fontSize = 36,
        width = width,
        height = height,
        shape = "roundedRect",
        cornerRadius = 15,
        labelColor = { default = common_ui.BUTTON_LABEL_COLOR_DEFAULT, over = common_ui.BUTTON_LABEL_COLOR_OVER },
        fillColor = { default = common_ui.BUTTON_FILL_COLOR_DEFAULT, over = common_ui.BUTTON_FILL_COLOR_OVER },
        strokeColor = { default = common_ui.BUTTON_STROKE_COLOR_DEFAULT, over = common_ui.BUTTON_STROKE_COLOR_OVER },
        strokeWidth = 2,
        onRelease = self:getOnReleasePlayButton()
    }

    -- Create the Pass button
    self.passButton = widget.newButton {
        x = display.contentWidth / 2 - width - 20,
        y = y,
        width = height,
        height = height,
        defaultFile = "images/pass_button_default.png",
        overFile = "images/pass_button_over.png",
        onRelease = self:getOnReleasePassButton()
    }

    -- Create the Reset button
    self.resetButton = widget.newButton {
        x = display.contentWidth / 2 + width + 20,
        y = y,
        width = height,
        height = height,
        defaultFile = "images/reset_button_default.png",
        overFile = "images/reset_button_over.png",
        onRelease = self:getOnReleaseResetButton()
    }

    group:insert(self.playMoveButton)
    group:insert(self.resetButton)
    group:insert(self.passButton)
    return group
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
            composer.gotoScene("scenes.title_scene", "fade")
        end
        return
    end

    local viewGroup = self.view

    if not common_ui.isValidDisplayObj(viewGroup) then
        print("ERROR - self.view isn't valid in play_game_scene.reset()")
        return
    end

    local oldTitleArea = self.titleAreaDisplayGroup
    local oldBoard = self.board
    local oldRack = self.rack

    self.titleAreaDisplayGroup = scene:createTitleAreaDisplayGroup(gameModel)

    self.board = self:createBoard(gameModel)
    self.rack = self:createRack(gameModel, self.board, self.creds.user)

    viewGroup:insert(self.titleAreaDisplayGroup)

    if gameModel.gameType == common_api.TWO_PLAYER then
        self:reDrawActionButtonsGroup()
    end

    viewGroup:insert(self.board.boardContainer)
    viewGroup:insert(self.rack.displayGroup)

    oldBoard:destroy()
    oldRack:destroy()
    common_ui.safeRemove(oldTitleArea)



    self.gameMenu.displayGroup:toFront() -- Put the game menu in front

end

getMoveDescription = function(moveJson)
    if moveJson.moveType == common_api.GRAB_TILES then
        local dir = moveJson.dir
        local lettersInOrder = moveJson.letters or ""
        if type(dir) == "string" and (dir == "W" or dir == "N") then
            lettersInOrder = lettersInOrder:reverse()
        end
        return "grabbed \"" .. lettersInOrder .. "\"!"
    elseif moveJson.moveType == common_api.PLAY_TILES then
        return "played \"" .. (moveJson.letters or "") ..
               "\" for " .. (moveJson.points or "0") .. " points!"
    elseif moveJson.moveType == common_api.PASS then
        return "passed."
    elseif moveJson.moveType == common_api.RESIGN then
        return "resigned."
    end
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

function scene:applyOpponentMoves(movesToDisplay, onApplyMovesComplete, skipResetBoard)

    local function afterApplyOpponentMove()
        print("Finished applying opponent's moves. Resetting board and showing modals.")
        if not skipResetBoard then
            self:fadeToTurn(false)
            self:resetBoardAndShowModals()
        end
        if type(onApplyMovesComplete) == "function" then
            onApplyMovesComplete()
        end
        self:resumePollForGame()
    end

    -- Reset the board and execute the callback even if there is no opponent's move
    if type(movesToDisplay) ~= "table" or #movesToDisplay <= 0 then
        print("movesToDisplay is empty or nil, so not applying opponent's move")
        afterApplyOpponentMove()
        return
    end

    local move = movesToDisplay[1]
    if type(move) ~= "table" then
        print("Opponent's move isn't a table, so not applying opponent's move")
        afterApplyOpponentMove()
        return
    end

    print("Applying opponent's move: " .. json.encode(move))

    self:showMoveModal(move, current_game.currentGame, function()
        if self.board then
            self:addToOpponentPoints(move.points)
            self.board:applyMove(move, self.rack, move.playerId == self.creds.user.id, afterApplyOpponentMove)
        end
    end)
end

function scene:getOnSendMoveSuccess()
    return function(updatedGameModel)
        local myMove = updatedGameModel.myMove

        if myMove then
            -- if updatedGameModel.myMove is set, then apply my move, before applying opponent's moves (if present)
            print("Showing modal before applying my move...")
            self:showMoveModal(myMove, updatedGameModel, function()
                -- Disable interaction while displaying move animations.
                self:disableAllInteraction()
                print("Adding to my points...")
                self:addToMyPoints(myMove.points)
                print("Applying my move...")
                self.board:applyMove(myMove, self.rack, true, function()
                    print("Finished applying myMove, now applying opponent's move(s)...")
                    self:applyUpdatedGame(updatedGameModel, true)
                end)
            end)
        else
            print("Applying opponent's move(s) only...")
            self:applyUpdatedGame(updatedGameModel, false)
        end
    end
end

function scene:addToMyPoints(numPoints)
    if type(numPoints) ~= "number" or numPoints <= 0 then
        return
    end

    local titleAreaDisplayGroup = self.titleAreaDisplayGroup
    if not common_ui.isValidDisplayObj(titleAreaDisplayGroup) then
        return
    end

    local leftPointsText = titleAreaDisplayGroup.leftPointsText
    if type(leftPointsText) ~= "table" then
        return
    end

    leftPointsText:addPoints(numPoints)
end

function scene:addToOpponentPoints(numPoints)
    if type(numPoints) ~= "number" or numPoints <= 0 then
        return
    end

    local titleAreaDisplayGroup = self.titleAreaDisplayGroup
    if not common_ui.isValidDisplayObj(titleAreaDisplayGroup) then
        return
    end

    local rightPointsText = titleAreaDisplayGroup.rightPointsText
    if type(rightPointsText) ~= "table" then
        return
    end

    rightPointsText:addPoints(numPoints)
end

function scene:showMoveModal(move, game, onModalClose)
    local specialDict = game and game.specialDict
    if type(specialDict) == "string" and move.specialWordsPlayed and #move.specialWordsPlayed > 0 then
        self:showBonusMoveModal(specialDict, move, onModalClose)
    else
        print("Found no special dict on move, showing ordinary modal. Dict was: " .. tostring(move.dict))
        self:showNormalMoveModal(move, game, onModalClose)
    end
end

function scene:showNormalMoveModal(move, game, onModalClose)
    if not self.creds or not self.creds.user then
        print "Error - creds not defined in play_game_scene."
        return
    end
    local moveDescr = getMoveDescription(move)
    local moveUsername
    if move.playerId == self.creds.user.id then
        --moveUsername = "You"
        onModalClose()
        return
    elseif move.playerId == game.player1 then
        moveUsername = game.player1Model.username
    else
        moveUsername = game.player2Model.username
    end

    local modal = common_ui.createInfoModal(moveUsername, moveDescr, onModalClose, nil, 48)
    self:safeAdd(modal)
end

function scene:safeAdd(displayObj)
    if common_ui.isValidDisplayObj(self.view) and common_ui.isValidDisplayObj(displayObj) then
       self.view:insert(displayObj)
    end
end

function scene:showBonusMoveModal(specialDict, move, onModalClose)
    if not self.creds or not self.creds.user then
        print "Error - creds not defined in play_game_scene."
        return
    end

    local isCurrentPlayer = move.playerId == self.creds.user.id

    local bonusPopup = bonus_popup.new(specialDict, move.specialWordsPlayed[1], isCurrentPlayer, onModalClose)
    bonusPopup:render()
    self.view:insert(bonusPopup.view)

    bonusPopup:show()
end

function scene:getOnRefreshGameSuccess()
    return function(updatedGameModel)
        self.refreshInProgress = nil
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

    local lastMoves = updatedGameModel and updatedGameModel.lastMoves
    self:applyOpponentMoves(lastMoves)

end

function scene:refreshGameFromServer()

    local currentGame = current_game.currentGame
    if not game_helpers.isValidGame(currentGame) then
        print("current_game.currentGame is invalid, cannot refresh from server.")
        return
    end
    if self.refreshInProgress then
        print("Not refreshing game - refresh in progress")
        return
    end

    self:pausePollForGame()
    self.refreshInProgress = true
    self.requestId =
        common_api.getGameById(currentGame.id, true, currentGame.moveNum, self:getOnRefreshGameSuccess(), self:getRefreshGameFail(), self:getRefreshGameFail(), false)
end


function scene:fadeToTurn(isOpponentTurn)
    if not common_ui.isValidDisplayObj(self.titleAreaDisplayGroup) or
       not common_ui.isValidDisplayObj(self.titleAreaDisplayGroup.leftCircle) or
       not common_ui.isValidDisplayObj(self.titleAreaDisplayGroup.rightCircle) then
        print("Error - titleAreaDisplayGroup or left/right circle isn't valid in play_game_scene:fadeToTurn")
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

        self:enableAllInteractionAndCancelGrab()

        if json and json.errorWord then
            if self.board then
                self.board:highlightErrorWord(json.errorWord)

                toast.new(json.errorMessage or "Word isn't in the dictionary", nil, nil, 3500)
            end
        elseif json and json.errorMessage then
            local message
            local messageFromServer = json.errorMessage
            if messageFromServer and messageFromServer:len() > 0 then
                message = messageFromServer
            else
                message = "Invalid move!"
            end
            native.showAlert("Oops...", message, { "Try again" })
        else
            native.showAlert("Network error", "A network error occurred", { "Try again" })
        end

    end
end

function scene:enableAllInteraction()
    if self.rack then
        self.rack:enableInteraction()
    end

    if self.board then
        self.board:enableInteraction()
    end
end

function scene:enableAllInteractionAndCancelGrab()
    if self.rack then
        self.rack:enableInteraction()
    end

    if self.board then
        self.board:enableInteraction()
        self.board:cancelGrab()
    end
end

function scene:disableAllInteraction()
    if self.board then
        self.board:disableInteraction()
    end
    if self.rack then
        self.rack:disableInteraction()
    end
end

function scene:getRefreshGameFail()
    return function(jsonResp)
        self.refreshInProgress = nil
        print("Error updating game.")
        --print("Error updating game:" .. json.encode(jsonResp))
        self:resumePollForGame()
    end
end

function scene:getOnSendMoveNetworkFail()
    return function(event)
        self:enableAllInteractionAndCancelGrab()

        common_api.showNetworkError()
    end
end

function scene:getOnGrabTiles()
    return function(tiles)
        print("Tiles grabbed!")
        if not current_game.isUsersTurn(self.creds.user) then
            local modal = common_ui.createInfoModal("Oops...", "It's not your turn")
            self:safeAdd(modal)
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
                        local moveJson = createGrabMoveJson(tiles)
                        self.requestId =
                            common_api.sendMove(moveJson, self:getOnSendMoveSuccess(), self:getOnSendMoveFail(), self:getOnSendMoveNetworkFail(), true)
                    elseif i == 2 then
                        self.board:cancelGrab()
                        -- Do nothing, user clicked "Nope"
                    end
                end
            end)
    end
end

function scene:getOnReleaseMyGamesButton()
    return function(event)
        local currentSceneName = composer.getSceneName("current")
        if currentSceneName == self.sceneName then
            composer.gotoScene("scenes.my_active_games_scene", "fade")
        end
    end
end

function scene:getOnReleasePlayButton()
    return function(event)
        if not current_game.isUsersTurn(self.creds.user) then
            local modal = common_ui.createInfoModal("Oops...", "It's not your turn")
            self:safeAdd(modal)
            return
        end

        local move = self.board:getCurrentPlayTilesMove()
        if move["errorMsg"] then
            local modal = common_ui.createInfoModal("Oops...", move["errorMsg"])
            self:safeAdd(modal)
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
                self.requestId =
                    common_api.sendMove(move, self:getOnSendMoveSuccess(), self:getOnSendMoveFail(), self:getOnSendMoveNetworkFail(), true)
                self:safeStopHighlightingTiles()
            else
                print("User clicked 'Nope'")
            end
        end)
    end
end

function scene:safeStopHighlightingTiles()
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end

    local pointsBubble = self.board and self.board.pointsBubble
    if not pointsBubble then
        return
    end

    pointsBubble:stopHighlightTiles()
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

function scene:getOnReleaseDictionaryButton()
    return function()
        local currentGame = current_game.currentGame
        if not currentGame or not currentGame.specialDict then
            local modal = common_ui.createInfoModal("No Special Dictionary", "This game doesn't have a special dictionary.", nil, 52)
            self:safeAdd(modal)
            return
        end
        local currentSceneName = composer.getSceneName("current")
        if currentSceneName == self.sceneName then
            composer.gotoScene("scenes.dictionary_scene", "fade")
        end
    end
end

function scene:reDrawActionButtonsGroup()
    if not common_ui.isValidDisplayObj(self.view) then
        return
    end
    local actionButtonsGroup = self:createActionButtonsForGameState()
    if actionButtonsGroup then
        common_ui.fadeOutThenRemove(self.actionButtonsGroup, { time = 500 })
        self.actionButtonsGroup = actionButtonsGroup
        self.view:insert(self.actionButtonsGroup)
        self.actionButtonsGroup.alpha = 0
        transition.fadeIn(self.actionButtonsGroup, { time = 500 })
    end
end

function scene:showGameOverModal()
    local gameModel = current_game.currentGame
    if not gameModel or gameModel.gameResult == common_api.IN_PROGRESS or gameModel.gameResult == common_api.OFFERED then
        print("Not displaying Game Over modal, game result is OFFERED or IN_PROGRESS")
        return false
    end

    if not self.creds or not self.creds.user then
        print("Not displaying Game Over modal, scene.creds is not defined")
        return false
    end

    local gameResult = gameModel.gameResult

    local authUser = self.creds.user

    local isMyWin = (gameResult == common_api.PLAYER1_WIN or gameResult == common_api.PLAYER2_RESIGN) and authUser.id == gameModel.player1 or
                    (gameResult == common_api.PLAYER2_WIN or gameResult == common_api.PLAYER1_RESIGN) and authUser.id == gameModel.player2

    local modalTitle, modalMessage
    if gameResult == common_api.PLAYER1_WIN then
        modalTitle = isMyWin and "Congratulations" or "Game Over"
        modalMessage = isMyWin and "You win!" or gameModel.player1Model.username .. " wins!"
    elseif gameResult == common_api.PLAYER2_WIN then
        modalTitle = isMyWin and "Congratulations" or "Game Over"
        modalMessage = isMyWin and "You win!" or gameModel.player2Model.username .. " wins!"
    elseif gameResult == common_api.TIE then
        modalTitle = "It's a tie!"
        modalMessage = "Time for a rematch"
    elseif gameResult == common_api.PLAYER1_TIMEOUT then
        modalMessage = (authUser.id == gameModel.player1 and "You" or gameModel.player1Model.username) .. " timed out after 2 weeks of inactivity."
    elseif gameResult == common_api.PLAYER2_TIMEOUT then
        modalMessage = (authUser.id == gameModel.player2 and "You" or gameModel.player2Model.username) .. " timed out after 2 weeks of inactivity."
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

    local function onClose()
        self:showRatingChangeModal()
    end

    local modal = common_ui.createInfoModal(modalTitle or "Game Over", modalMessage, onClose, nil, 52)
    self:safeAdd(modal)
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

    local function showBackToMainMenuPopup()
        if common_ui.isValidDisplayObj(self.view) then
            local popup = back_to_main_menu_popup.new(self)
            self.view:insert(popup:render())
            popup:show()
        end
    end

    if not ratingIncrease or ratingIncrease <= 0 then
        print("In showRatingChangeModal, we must be viewing an old game, because the rating increase = " .. tostring(ratingIncrease))
        showBackToMainMenuPopup()
        return
    end

    local modal = game_ui.createRatingUpModal(self, ratingIncrease, showBackToMainMenuPopup)
    self.view:insert(modal)
end

function scene:pass()
    local passMove = common_api.getPassMove(current_game.currentGame, self.creds.user.id)
    self.requestId =
        common_api.sendMove(passMove, self:getOnSendMoveSuccess(), self:getOnSendMoveFail(), self:getOnSendMoveNetworkFail(), true)
end

function scene:resign()
    local resignMove = common_api.getResignMove(current_game.currentGame, self.creds.user.id)
    self.requestId =
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
        composer.gotoScene("scenes.create_game_scene", "fade")

        local challengedPopup = challenged_popup.new(userModel)
        challengedPopup:show()
    end
end

function scene:isValidGameScene()
    return self.view and self.board and self.rack and self.creds and true
end

function scene:startPollForGame()
    if current_game.currentGame and current_game.currentGame.gameType == common_api.TWO_PLAYER then
        self:cancelPollForGame()
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

