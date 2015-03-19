local composer = require( "composer" )
local widget = require( "widget" )
local json = require("json")
local board_helpers = require("common.board_helpers")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local current_game = require("globals.current_game")
local board_class = require("classes.board_class")
local rack_class = require("classes.rack_class")
local login_common = require("login.login_common")
local game_menu_class = require("classes.game_menu_class")
local scene = composer.newScene()

-- The board object
local board
-- The rack object
local rack
-- The options menu
local gameMenu
-- The options button
local optionsButton

-- Display objects
local titleAreaDisplayGroup
local actionButtonsGroup
local playMoveButton
local resetButton

-- Local helpers pre-declaration
local checkGameModelIsDefined
local doesAuthUserMatchGame
local createTitleAreaDisplayGroup
local createBoard
local createRack
local createActionButtonsGroup
local drawOptionsButton
local onReleaseOptionsButton
local onReleasePlayButton
local onReleaseResetButton
local onGrabTiles
local tilesToStr
local createGrabMoveJson

local completeMove
local getSendMoveSuccessCallback
local onSendMoveSuccess
local onSendMoveFail
local onSendMoveNetworkFail

local showPassModal
local pass
local reset
local resetBoardAndShowModals
local showGameOverModal
local showNoMovesModal
local getMoveDescription

scene.sceneName = "scenes.play_game_scene"

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view

    local gameModel = checkGameModelIsDefined()

    if not gameModel then
        return
    end

    scene.creds = login_common.fetchCredentials()

    if not scene.creds then
        login_common.dumpToLoggedOutScene(self.sceneName)
    end

    if not doesAuthUserMatchGame(gameModel, scene.creds.user) then
        return
    end

    local background = common_ui.create_background()

    titleAreaDisplayGroup = createTitleAreaDisplayGroup(gameModel, scene.creds.user)

    board = createBoard(gameModel)

    rack = createRack(gameModel, board)

    gameMenu = game_menu_class.new(display.contentWidth / 2, display.contentHeight / 2 - 50, function()
        gameMenu:close()
        showPassModal()
    end)

    actionButtonsGroup = createActionButtonsGroup(display.contentWidth + 195, 200, 64, onReleasePlayButton, onReleaseResetButton)

    optionsButton = drawOptionsButton(display.contentWidth - 75, display.contentHeight - 60, 90)

    sceneGroup:insert(background)
    sceneGroup:insert(titleAreaDisplayGroup)

    sceneGroup:insert(board.boardContainer)
    sceneGroup:insert(rack.displayGroup)
    sceneGroup:insert(optionsButton)
    sceneGroup:insert(actionButtonsGroup)
    sceneGroup:insert(gameMenu.displayGroup)

end

createBoard = function(gameModel)
    local boardWidth = display.contentWidth - 20
    local boardCenterX = display.contentWidth / 2
    local boardCenterY = display.contentWidth / 2 + 180

    return board_class.new(gameModel, boardCenterX, boardCenterY, boardWidth, 20, onGrabTiles)
end

createRack = function(gameModel, board)
    return rack_class.new(gameModel, 100, display.contentWidth + 274, 7, 25, board)
end

-- "scene:show()"
function scene:show( event )

    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        scene.creds = login_common.fetchCredentials() -- Check if the current user is logged in.
        if not scene.creds then
            login_common.dumpToLoggedOutScene(self.sceneName)
        end

    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        showGameOverModal()
        showNoMovesModal()
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view
    scene.creds = nil
    board, rack, gameMenu, titleAreaDisplayGroup, actionButtonsGroup, playMoveButton, resetButton = nil, nil, nil, nil, nil, nil, nil

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end

-- Local helpers
checkGameModelIsDefined = function()
    local gameModel = current_game.currentGame

    if not gameModel then
        print ("Error - no current game is defined in the current_game module.")
        local currentScene = composer.getSceneName("current")
        if currentScene == scene.sceneName then
            composer.gotoScene( "scenes.title_scene" )
            composer.removeScene(currentScene, false)
        end
    end

    return gameModel
end

doesAuthUserMatchGame = function(gameModel, authUser)
    if authUser.id ~= gameModel.player1 and authUser.id ~= gameModel.player2 then
        print("Error - incorrect authenticated user for game! User doesn't match either player.")
        print("Auth user = " .. json.encode(authUser))
        print("Player 1 = " .. json.encode(gameModel.player1Model))
        print("Player 2 = " .. json.encode(gameModel.player2Model))
        login_common.logout()
        local currentScene = composer.getSceneName("current")
        composer.gotoScene("scenes.title_scene")
        composer.removeScene(currentScene, false)
        return false
    end
    return true
end

createTitleAreaDisplayGroup = function(gameModel)
    local authUserIsPlayer1 = gameModel.player1 == scene.creds.user.id
    local isAuthUserTurn = gameModel.player1Turn and authUserIsPlayer1 or not gameModel.player1Turn and not authUserIsPlayer1
    local player1 = gameModel.player1Model
    local player2 = gameModel.player2Model
    local leftUsername, rightUsername, leftPoints, rightPoints, leftFont, rightFont
    if authUserIsPlayer1 then
        leftUsername, rightUsername = player1.username, player2.username
        leftPoints, rightPoints = gameModel.player1Points, gameModel.player2Points
    else
        leftUsername, rightUsername = player2.username, player1.username
        leftPoints, rightPoints = gameModel.player2Points, gameModel.player1Points
    end

    if isAuthUserTurn then
        leftFont = native.systemFontBold
        rightFont = native.systemFont
    else
        leftFont = native.systemFont
        rightFont = native.systemFontBold
    end

    local group = display.newGroup( )

    -- The actual displayed username text
    if leftUsername:len() > 11 then
        leftUsername = leftUsername:sub(1, 11) .. ".."
    end
    if rightUsername:len() > 11 then
        rightUsername = rightUsername:sub(1, 11) .. ".."
    end

    -- Create the username texts
    local leftPlayerText = display.newText( {
        text = leftUsername,
        x = 175, y = 100,
        font = leftFont,
        fontSize = 40,
        width = 400,
        height = 50,
        align = "center"
        })
    leftPlayerText:setFillColor( 0, 0, 0 )

    local rightPlayerText = display.newText( {
        text = rightUsername,
        x = 575, y = 100,
        font = rightFont,
        fontSize = 40,
        width = 400, height = 50,
        align = "center" })
    rightPlayerText:setFillColor( 0, 0, 0 )

    -- Create sparkles
    local leftSparkles = display.newImageRect("images/pencil-circled.png", 325, 75)
    leftSparkles.x, leftSparkles.y, leftSparkles.alpha = 175, 100, 0

    local rightSparkles = display.newImageRect("images/pencil-circled.png", 325, 75)
    rightSparkles.x, rightSparkles.y, rightSparkles.alpha = 575, 100, 0

    -- Create vs. text
    local versusText = display.newText("vs.", 375, 100, native.systemFontBold, 50 )
    versusText:setFillColor( 0, 0, 0 )

    -- Create point displays
    local leftPointsText = display.newText( "( " .. leftPoints .. " points )", 175, 150, native.systemFontBold, 30 )
    leftPointsText:setFillColor( 0, 0, 0 )
    function leftPointsText:setPoints(points)
        self.text = "( " .. points .. " points )"
    end

    local rightPointsText = display.newText( "( " .. rightPoints .. " points )", 575, 150, native.systemFontBold, 30 )
    rightPointsText:setFillColor( 0, 0, 0 )
    function rightPointsText:setPoints(points)
        self.text = "( " .. points .. " points )"
    end

    group:insert(leftPlayerText)
    group:insert(rightPlayerText)
    group:insert(versusText)
    group:insert(leftPointsText)
    group:insert(rightPointsText)
    group:insert(leftSparkles)
    group:insert(rightSparkles)

    -- Store sparkles in group object for later use
    group.leftSparkles, group.rightSparkles = leftSparkles, rightSparkles
    group.leftPointsText, group.rightPointsText = leftPointsText, rightPointsText

    if isAuthUserTurn then
        leftSparkles.alpha = 1
    else
        rightSparkles.alpha = 1
    end

    return group
end

createActionButtonsGroup = function(startY, width, height, onPlayButtonRelease, onResetButtonRelease)
    local group = display.newGroup()
    -- Create the Play Word button
    local x1 = display.contentWidth / 2 - width / 2 - 5
    local y = startY + height / 2
    playMoveButton = widget.newButton {
        x = x1,
        y = y,
        emboss = true,
        label = "Play word",
        fontSize = 32,
        labelColor = { default = {1, 0.9, 0.9}, over = { 0, 0, 0 } },
        width = width,
        height = height,
        shape = "roundedRect",
        cornerRadius = 15,
        fillColor = { default={ 0.93, 0.48, 0.01, 0.7 }, over={ 0.76, 0, 0.13, 1 } },
        strokeColor = { 1, 0.2, 0.2 },
        strokeRadius = 10,
        onRelease = onPlayButtonRelease
    }

    -- Create the Reset button
    local x2 = display.contentWidth / 2 + width / 2 + 5
    resetButton = widget.newButton {
        x = x2,
        y = y,
        emboss = true,
        label = "Reset",
        fontSize = 32,
        labelColor = { default = {1, 0.9, 0.9}, over = { 0, 0, 0 } },
        width = width,
        height = height,
        shape = "roundedRect",
        cornerRadius = 15,
        fillColor = { default={ 0.93, 0.48, 0.01, 0.7 }, over={ 0.76, 0, 0.13, 1 } },
        strokeColor = { 1, 0.2, 0.2 },
        strokeRadius = 10,
        onEvent = onResetButtonRelease
    }

    group:insert(playMoveButton)
    group:insert(resetButton)
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
        onRelease = onReleaseOptionsButton
    })
end

onReleaseOptionsButton = function(event)
    print ("Options button pressed!")
    gameMenu:toggle()
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

reset = function()
    local gameModel = current_game.currentGame
    if not gameModel then
        print("Error - current_game.currentGame wasn't defined when reset() was called in single player scene")
        local currentScene = composer.getSceneName("current")
        if currentScene == scene.sceneName then
            composer.gotoScene("scenes.title_scene")
            composer.removeScene(currentScene, false)
        end
        return
    end

    local oldTitleArea = titleAreaDisplayGroup
    local oldBoard = board
    local oldRack = rack

    titleAreaDisplayGroup = createTitleAreaDisplayGroup(gameModel, scene.creds.user)

    board = createBoard(gameModel)
    rack = createRack(gameModel, board)

    local viewGroup = scene.view
    viewGroup:insert(board.boardContainer)
    viewGroup:insert(rack.displayGroup)
    viewGroup:insert(titleAreaDisplayGroup)

    optionsButton:toFront() -- Put the options button on top of the new rack.
    gameMenu.displayGroup:toFront() -- Put the game menu in front

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

resetBoardAndShowModals = function()
    reset()
    showGameOverModal()
    showNoMovesModal()
end

onSendMoveSuccess = function(updatedGameModel)
    current_game.currentGame = updatedGameModel
    local sceneGroup = scene.view
    local FADE_TIME = 1500
    if updatedGameModel.gameType == common_api.SINGLE_PLAYER and updatedGameModel.player1Turn then
        -- If it's the human player's turn again, then the AI just played a move.
        local onFadeInComplete = function()
            common_ui.create_info_modal(updatedGameModel.player2Model.username,
                                                      getMoveDescription(updatedGameModel.lastMove),
                                                      function()
                titleAreaDisplayGroup.rightPointsText:setPoints( updatedGameModel.player2Points )
                transition.fadeIn(titleAreaDisplayGroup.leftSparkles, {time = FADE_TIME })
                transition.fadeOut(titleAreaDisplayGroup.rightSparkles, {time = FADE_TIME, onComplete = resetBoardAndShowModals})

            end)
        end
        titleAreaDisplayGroup.leftPointsText:setPoints( updatedGameModel.player1Points )
        transition.fadeOut(titleAreaDisplayGroup.leftSparkles, {time = FADE_TIME })
        transition.fadeIn(titleAreaDisplayGroup.rightSparkles, {time = FADE_TIME, onComplete = onFadeInComplete })

    else
        transition.fadeOut(titleAreaDisplayGroup.leftSparkles, {time = FADE_TIME, onComplete = resetBoardAndShowModals })
        transition.fadeIn(titleAreaDisplayGroup.rightSparkles, {time = FADE_TIME})
    end


    -- TODO: display the previous move played by the AI in some manner
end

onSendMoveFail = function(json)
    if json and json["errorMessage"] then
        local message
        local messageFromServer = json["errorMessage"]
        if messageFromServer and messageFromServer:len() > 0 then
            message = messageFromServer
        else
            message = "Invalid move!"
        end
        native.showAlert( "Oops...", message, { "Try again" }, function(event)
            if event.action == "clicked" then
               rack:enableInteraction()
               board:enableInteraction()
            end
        end)
    end
    board:cancel_grab()
end

onSendMoveNetworkFail = function(event)
    native.showAlert("Network Error", "Network error, please try again", { "OK" }, function(event)
        if event.action == "clicked" then
           rack:enableInteraction()
           board:enableInteraction()
        end
    end)
    board:cancel_grab()
end

onGrabTiles = function(tiles)
    print("Tiles grabbed!")
    if not current_game.isUsersTurn(scene.creds.user) then
       common_ui.create_info_modal("Oops...", "It's not your turn")
       board:cancel_grab()
       return
    end

    local lettersStr = tilesToStr(tiles, ", ")

    native.showAlert("Grab tiles?", "Grab tiles: " .. lettersStr .. "?", {"OK", "Nope"}, 
        function(event)
            if event.action == "clicked" then
                local i = event.index
                if i == 1 then
                    rack:returnAllTiles()
                    board:disableInteraction()
                    rack:disableInteraction()
                    local moveJson = createGrabMoveJson(tiles)
                    common_api.sendMove(moveJson, onSendMoveSuccess, onSendMoveFail, onSendMoveNetworkFail, true)
                elseif i == 2 then
                    board:cancel_grab()
                    -- Do nothing, user clicked "Nope"
                end
            end
        end)

end

onReleasePlayButton = function(event)
    if not current_game.isUsersTurn(scene.creds.user) then
        common_ui.create_info_modal("Oops...", "It's not your turn")
        return
    end

    local move = board:getCurrentPlayTilesMove()
    if move["errorMsg"] then
        native.showAlert("Oops...", move["errorMsg"], {"Try again"} )
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
            board:disableInteraction()
            rack:disableInteraction()
            common_api.sendMove(move, onSendMoveSuccess, onSendMoveFail, onSendMoveNetworkFail, true)
        else
            print("User clicked 'Nope'")
        end
    end)
end

onReleaseResetButton = function(event)
    rack:returnAllTiles()
end

showGameOverModal = function()
    local gameModel = current_game.currentGame
    if not gameModel or gameModel.gameResult == common_api.IN_PROGRESS then
        print("Not displaying Game Over modal, game result is " .. tostring(gameModel and gameModel.gameResult) )
        return
    end

    playMoveButton:setEnabled(false)
    resetButton:setEnabled(false)

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

    local modal = common_ui.create_info_modal("Game Over", modalMessage, nil, nil, nil)
    scene.view:insert(modal)

end

showNoMovesModal = function()
    local gameModel = current_game.currentGame
    if not gameModel or gameModel.gameResult ~= common_api.IN_PROGRESS or not board then
        print("Game is over, not showing No Moves Modal")
        return
    end

    if gameModel.player1Rack:len() > 0 or gameModel.tiles:upper() ~= gameModel.tiles then
       print("Player 1 rack is non-empty, or game still has tiles to grab. Not showing No Moves Modal")
        return
    end

    local modalMessage = "You must pass.\nTouch to continue..."

    common_ui.create_info_modal("No Moves!", modalMessage, pass)
end

pass = function()
    local passMove = common_api.getPassMove(current_game.currentGame)
    common_api.sendMove(passMove, onSendMoveSuccess, onSendMoveFail, onSendMoveNetworkFail, true)
end

showPassModal = function()
    native.showAlert( "Pass?", "Are you sure you want to pass?" , { "Yes", "Nope" }, function(event)
        if event.action == "clicked" then
            if event.index == 1 then
                pass()
            end
        end
    end )
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

