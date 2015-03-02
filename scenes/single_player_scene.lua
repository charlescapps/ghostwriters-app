local composer = require( "composer" )
local widget = require( "widget" )
local json = require("json")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local current_game = require("globals.current_game")
local board_class = require("classes.board_class")
local rack_class = require("classes.rack_class")
local login_common = require("login.login_common")
local scene = composer.newScene()

-- The board object
local board
-- The rack object
local rack

-- Display objects
local titleAreaDisplayGroup

-- Local helpers pre-declaration
local checkGameModelIsDefined
local doesAuthUserMatchGame
local createTitleAreaDiplayGroup
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

local reset

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view

    local gameModel = checkGameModelIsDefined()

    if not gameModel then
        return
    end

    local authUser = login_common.checkCredentials()

    if not doesAuthUserMatchGame(gameModel, authUser) then
        return
    end

    local background = common_ui.create_background()

    titleAreaDisplayGroup = createTitleAreaDiplayGroup(gameModel, authUser)

    board = createBoard(gameModel)

    rack = createRack(gameModel, board)

    local actionButtonsGroup = createActionButtonsGroup(display.contentWidth + 220, 200, 70, onReleasePlayButton, onReleaseResetButton)

    local optionsButton = drawOptionsButton(display.contentWidth - 75, display.contentWidth + 470, 100)

    sceneGroup:insert(background)
    sceneGroup:insert(titleAreaDisplayGroup)

    sceneGroup:insert(board.boardContainer)
    sceneGroup:insert(rack.displayGroup)
    sceneGroup:insert(optionsButton)
    sceneGroup:insert(actionButtonsGroup)

end

createBoard = function(gameModel)
    local boardWidth = display.contentWidth - 20
    local boardCenterX = display.contentWidth / 2
    local boardCenterY = display.contentWidth / 2 + 200

    return board_class.new(gameModel, boardCenterX, boardCenterY, boardWidth, onGrabTiles)
end

createRack = function(gameModel, board)
    return rack_class.new(gameModel, 75, display.contentWidth + 295, 7, 25, board)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phases

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        scene.user = login_common.checkCredentials() -- Check if the current user is logged in.

    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
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

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end

-- Local helpers
checkGameModelIsDefined = function()
    local gameModel = current_game.currentGame

    if not gameModel then
        print ("Error - no current game is defined in the current_game module.")
        composer.gotoScene( "scenes.title_scene" )
        local currentScene = composer.getSceneName( "current" )
        composer.removeScene( currentScene, false )
    end

    return gameModel
end

doesAuthUserMatchGame = function(gameModel, authUser)
    if authUser.id ~= gameModel.player1 then
        print("Error - player1 must be the authenticated user for Single Player games!")
        print("Auth user = " .. json.encode(authUser))
        print("Player 1 = " .. json.encode(gameModel.player1Model))
        composer.gotoScene("scenes.title_scene")
        return false
    end
    return true
end

createTitleAreaDiplayGroup = function(gameModel, authUser)
    local player1 = gameModel.player1Model
    local player2 = gameModel.player2Model
    local player1Username, player2Username, player1Points, player2Points
    player1Username = player1.username
    player2Username = player2.username
    player1Points = gameModel.player1Points
    player2Points = gameModel.player2Points


    local group = display.newGroup( )

    -- Create player name displays
    local player1Scroll = widget.newScrollView {
        x = 175, y = 100,
        width = 250, height = 50,
        verticalScrollDisabled = true,
        hideBackground = true
    }
    if player1Username:len() < 10 then
        local pads = string.rep( " ", 10 - player1Username:len() )
        player1Username = pads .. player1Username
    end
    local player1Text = display.newText( {
        text = player1Username, 
        x = 200, y = 25, 
        font = native.systemFont, 
        fontSize = 40,
        width = 400,
        height = 50,
        align = "left" 
        })
    player1Text:setFillColor( 0, 0, 0 )
    player1Scroll:insert(player1Text)

    local player2Scroll = widget.newScrollView {
        x = 575, y = 100,
        width = 250, height = 50,
        verticalScrollDisabled = true,
        hideBackground = true,
        friction = 2.0
    }
    local player2Text = display.newText( {
        text = player2Username, 
        x = 200, y = 25, 
        font = native.systemFont, 
        fontSize = 40,
        width = 400, height = 50,
        align = "left" })
    player2Text:setFillColor( 0, 0, 0 )
    player2Scroll:insert(player2Text)

    -- Create vs. text

    local versusText = display.newText("vs.", 375, 100, native.systemFontBold, 50 )
    versusText:setFillColor( 0, 0, 0 )

    -- Create point displays
    local player1PointsText = display.newText( "( " .. player1Points .. " points )", 175, 150, native.systemFontBold, 30 )
    player1PointsText:setFillColor( 0, 0, 0 )
    local player2PointsText = display.newText( "( " .. player2Points .. " points )", 575, 150, native.systemFontBold, 30 )
    player2PointsText:setFillColor( 0, 0, 0 )


    group:insert(player1Scroll)
    group:insert(player2Scroll)
    group:insert(versusText)
    group:insert(player1PointsText)
    group:insert(player2PointsText)

    return group

end

createActionButtonsGroup = function(startY, width, height, onPlayButtonRelease, onResetButtonRelease)
    local group = display.newGroup()
    -- Create the Play Word button
    local x1 = display.contentWidth / 2 - width / 2 - 5
    local y = startY + height / 2
    local playMoveButton = widget.newButton {
        x = x1,
        y = y,
        emboss = true,
        label = "Play word",
        fontSize = 30,
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
    local resetButton = widget.newButton {
        x = x2,
        y = y,
        emboss = true,
        label = "Reset",
        fontSize = 30,
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
        composer.gotoScene("scenes.title_scene")
        return
    end

    local authUser = login_common.checkCredentials()
    if not authUser then
        return
    end

    local oldTitleArea = titleAreaDisplayGroup
    local oldBoard = board
    local oldRack = rack

    titleAreaDisplayGroup = createTitleAreaDiplayGroup(gameModel, authUser)
    if not titleAreaDisplayGroup then
        return
    end
    board = createBoard(gameModel)
    rack = createRack(gameModel, board)

    local viewGroup = scene.view
    viewGroup:insert(board.boardContainer)
    viewGroup:insert(rack.displayGroup)

    oldBoard:destroy()
    oldRack:destroy()
    oldTitleArea:removeSelf()

end


onSendMoveSuccess = function(updatedGameModel)
    current_game.currentGame = updatedGameModel
    reset()

    -- TODO: display the previous move played by the AI in some manner
end

onSendMoveFail = function(json)
    if json and json["errorMessage"] then
        native.showAlert( "Oops...", "Invalid move: " .. json["errorMessage"], { "Try again" })
    else
        native.showAlert("Oops...", "Network error, please try again", { "OK" })
    end
    board:cancel_grab()
end


onGrabTiles = function(tiles)
    print("Tiles grabbed!")
    local lettersStr = tilesToStr(tiles, ", ")
    native.showAlert("Grab tiles?", "Grab tiles: " .. lettersStr .. "?", {"OK", "Nope"}, 
        function(event)
            if event.action == "clicked" then
                local i = event.index
                if i == 1 then
                    local moveJson = createGrabMoveJson(tiles)
                    common_api.sendMove(moveJson, onSendMoveSuccess, onSendMoveFail)
                elseif i == 2 then
                    -- Do nothing, user clicked "Nope"
                end
            end
        end)
end

onReleasePlayButton = function(event)
    local move = board:getCurrentPlayTilesMove()
    if move["errorMsg"] then
        native.showAlert("Try Again", "Please try again, " .. move["errorMsg"] )
        return
    end
    local gameModel = current_game.currentGame
    if not gameModel then
        print("Error - no game model defined in current_game module when clicking Play button.")
        return
    end
    move.gameId = gameModel.id
    print("Sending move: " .. json.encode(move))
    native.showAlert("Send move?", "Play word " .. move.letters .. " ?", { "Yes", "Nope" }, function(event)
        local index = event.index
        if index == 1 then
            common_api.sendMove(move, onSendMoveSuccess, onSendMoveFail)
        else
            print("User clicked 'Nope'")
        end
    end)
end

onReleaseResetButton = function(event)
    rack:returnAllTiles()
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

