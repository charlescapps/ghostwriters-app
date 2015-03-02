local composer = require( "composer" )
local common_api = require( "common.common_api" )
local common_ui = require( "common.common_ui" )
local new_game_data = require("globals.new_game_data")
local scene = composer.newScene()

local createBackButton

local function getOnReleaseListener(sizeName)
    return function(event)
        new_game_data.boardSize = sizeName
        composer.gotoScene( "scenes.choose_game_density_scene", "fade" )
    end

end


-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    local backButton = createBackButton()

    local smallBoardGrp = common_ui.create_img_button_group("images/small_board.jpg", "images/small_board_dark.jpg", 200, "Short story", "(9x9 board)", getOnReleaseListener(common_api.SMALL_SIZE))
    local mediumBoardGrp = common_ui.create_img_button_group("images/medium_board.jpg", "images/medium_board_dark.jpg", 600, "Novel", "(13x13 board)", getOnReleaseListener(common_api.MEDIUM_SIZE))
    local largeBoardGrp = common_ui.create_img_button_group("images/large_board.jpg", "images/large_board_dark.jpg", 1000, "Necronomicon", "(15x15 board)", getOnReleaseListener(common_api.LARGE_SIZE))

    sceneGroup:insert(background)
    sceneGroup:insert(backButton)
    sceneGroup:insert(smallBoardGrp)
    sceneGroup:insert(mediumBoardGrp)
    sceneGroup:insert(largeBoardGrp)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phases

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        new_game_data.boardSize = nil
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
createBackButton = function()
    local previousScene, beforeTransition
    if new_game_data.gameType == common_api.TWO_PLAYER then
        previousScene = "scenes.title_scene"
        beforeTransition = function()
            new_game_data.clearAll()
        end
    else
        previousScene = "scenes.choose_ai_scene"
        beforeTransition = function()
            new_game_data.boardSize, new_game_data.aiType = nil, nil
        end
    end

    return common_ui.create_back_button(100, 100, previousScene, beforeTransition)
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

