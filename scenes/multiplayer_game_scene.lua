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
local player1PointsText
local player2PointsText

-- Local helpers pre-declaration
local createTitleAreaDiplayGroup
local drawOptionsButton
local onReleaseOptionsButton
local onGrabTiles
local tilesToStr
local createGrabMoveJson

local onSendMoveSuccess
local onSendMoveFail

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view

    if not current_game.currentGame then
        print ("Error - no current game is defined in the current_game module.")
        composer.gotoScene( "scenes.title_scene" )
        local currentScene = composer.getSceneName( "current" )
        composer.removeScene( currentScene, false )
        return
    end

    local player1 = login_common.checkCredentials()

    local gameModel = current_game.currentGame
    local boardWidth = display.contentWidth - 20
    local boardCenterX = display.contentWidth / 2
    local boardCenterY = display.contentWidth / 2 + 200

    board = board_class.new(gameModel, boardCenterX, boardCenterY, boardWidth, onGrabTiles)
    local boardStr = board:getSquaresStr()
    print("\n" .. boardStr)

    local tilesStr = board:getTilesStr()
    print("\n" .. tilesStr)

    local background = common_ui.create_background()
    
    local boardTexture = common_ui.create_image("images/wood-texture.jpg", display.contentWidth, display.contentWidth, 
        boardCenterX, boardCenterY)

    local player2= gameModel["player2Model"]

    local titleGroup = createTitleAreaDiplayGroup(player1.username, player2.username, gameModel.player1Points, gameModel.player2Points)

    local boardGroup = board:createBoardGroup()

    rack = rack_class.new(gameModel, 100, display.contentWidth + 220, 7, 25)
    local rackGroup = rack.displayGroup

    local optionsButton = drawOptionsButton(display.contentWidth - 75, display.contentWidth + 470, 100)

    sceneGroup:insert(background)
    sceneGroup:insert(boardTexture)
    sceneGroup:insert(titleGroup)

    sceneGroup:insert(boardGroup)
    sceneGroup:insert(rackGroup)
    sceneGroup:insert(optionsButton)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phases

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        scene.user = login_common.checkCredentials() -- Check if the current user is logged in.
        if not scene.gameModel then
            print ("Error - no game model present for multiplayer game!")
        else
            gameModel = scene.gameModel
            print ("Game model: " .. json.encode(scene.gameModel))
        end

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
createTitleAreaDiplayGroup = function(player1Username, player2Username, player1Points, player2Points)
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
    player1PointsText = display.newText( "( " .. player1Points .. " points )", 175, 150, native.systemFontBold, 30 )
    player1PointsText:setFillColor( 0, 0, 0 )
    player2PointsText = display.newText( "( " .. player2Points .. " points )", 575, 150, native.systemFontBold, 30 )
    player2PointsText:setFillColor( 0, 0, 0 )


    group:insert(player1Scroll)
    group:insert(player2Scroll)
    group:insert(versusText)
    group:insert(player1PointsText)
    group:insert(player2PointsText)

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
        moveType = "GRAB_TILES",
        start = { r = tiles[1].row - 1, c = tiles[1].col - 1 },
        dir = dir
     }

end

onSendMoveSucces = function(updatedGameModel)
    rack:addTiles(updatedGameModel.lastMove.tiles)
    board:complete_grab()
    current_game.currentGame = updatedGameModel
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
                    common_api.sendMove(moveJson, onSendMoveSucces, onSendMoveFail)
                elseif i == 2 then
                    -- Do nothing, user clicked "Nope"
                end
            end
        end)
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

