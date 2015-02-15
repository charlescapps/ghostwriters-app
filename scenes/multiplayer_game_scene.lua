local composer = require( "composer" )
local widget = require( "widget" )
local json = require("json")
local common_ui = require("common.common_ui")
local current_game = require("globals.current_game")
local board_class = require("classes.board_class")
local scene = composer.newScene()

local board


-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view

    if not current_game.currentGame then
        print ("Error - no current game is defined in the current_game module.")
    end

    local gameModel = current_game.currentGame
    board = board_class.new(gameModel)
    local boardStr = board:getSquaresStr()
    print("\n" .. boardStr)

    local tilesStr = board:getTilesStr()
    print("\n" .. tilesStr)

    local background = common_ui.create_background()
    local boardCenterX = display.contentWidth / 2
    local boardCenterY = display.contentWidth / 2 + 200
    local boardTexture = common_ui.create_image("images/wood-texture.jpg", display.contentWidth, display.contentWidth, 
        boardCenterX, boardCenterY)

    local player2Model = gameModel["player2Model"]
    local titleText = "Game with " .. player2Model["username"]
    local title = common_ui.create_title(titleText, 100, {0, 0, 0}, 50)

    local squaresGroup = board:createSquaresGroup(display.contentWidth - 20)
    squaresGroup.x = 10
    squaresGroup.y = 210

    local tilesGroup = board:createTilesGroup(display.contentWidth - 20)
    tilesGroup.x = 10
    tilesGroup.y = 210

    sceneGroup:insert(background)
    sceneGroup:insert(boardTexture)
    sceneGroup:insert(title)
    sceneGroup:insert(squaresGroup)
    sceneGroup:insert(tilesGroup)
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


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

