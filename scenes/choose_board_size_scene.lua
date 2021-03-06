local composer = require( "composer" )
local common_api = require( "common.common_api" )
local common_ui = require( "common.common_ui" )
local new_game_data = require("globals.new_game_data")
local nav = require("common.nav")
local game_helpers = require("common.game_helpers")
local scene_helpers = require("common.scene_helpers")
local scene = composer.newScene()

scene.sceneName = "scenes.choose_board_size_scene"

local createBackButton

local function getOnReleaseListener(sizeName)
    return function(event)
        new_game_data.boardSize = sizeName
        nav.goToSceneFrom(scene.sceneName, "scenes.create_game_scene", "fade" )
    end
end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.createBackground()
    self.backButton = createBackButton()

    local smallBoardGrp = common_ui.createImageButtonWithText("images/small_board.png", "images/small_board_over.png", 225, "Short story", "(5x5 board)", getOnReleaseListener(common_api.SMALL_SIZE), 250)
    local mediumBoardGrp = common_ui.createImageButtonWithText("images/medium_board.png", "images/medium_board_over.png", 620, "Novel", "(9x9 board)", getOnReleaseListener(common_api.MEDIUM_SIZE), 300)
    local largeBoardGrp = common_ui.createImageButtonWithText("images/large_board.png", "images/large_board_over.png", 1050, "Tome", "(13x13 board)", getOnReleaseListener(common_api.LARGE_SIZE), 350)

    sceneGroup:insert(background)
    sceneGroup:insert(self.backButton)
    sceneGroup:insert(smallBoardGrp)
    sceneGroup:insert(mediumBoardGrp)
    sceneGroup:insert(largeBoardGrp)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        new_game_data.boardSize = nil
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        scene_helpers.onDidShowScene(self)
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        scene_helpers.onWillHideScene()
    elseif ( phase == "did" ) then
        -- Set self.view to nil, so that create() will be called each time we load this scene.
        self.view = nil
        composer.removeScene(self.sceneName, false)
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
        local storedScene = composer.getVariable(game_helpers.START_GAME_FROM_SCENE_KEY)
        previousScene = storedScene and storedScene:len() > 0 and storedScene or "scenes.title_scene"
        beforeTransition = function()
            new_game_data.clearAll()
            composer.setVariable(game_helpers.START_GAME_FROM_SCENE_KEY, "")
        end
    else
        previousScene = "scenes.choose_ai_scene"
        beforeTransition = function()
            new_game_data.boardSize, new_game_data.aiType = nil, nil
            composer.setVariable(game_helpers.START_GAME_FROM_SCENE_KEY, "")
        end
    end

    return common_ui.createBackButton(100, 120, previousScene, beforeTransition)
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

