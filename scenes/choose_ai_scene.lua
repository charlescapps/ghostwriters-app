local composer = require( "composer" )
local common_api = require( "common.common_api" )
local common_ui = require( "common.common_ui" )
local new_game_data = require("globals.new_game_data")
local nav = require("common.nav")
local scene_helpers = require("common.scene_helpers")
local game_helpers = require("common.game_helpers")
local choose_ai_first_time_tip = require("tips.choose_ai_first_time_tip")

local scene = composer.newScene()

scene.sceneName = "scenes.choose_ai_scene"

local function getOnReleaseListener(aiType)
    return function(event)
        new_game_data.aiType = aiType
        new_game_data.gameType = common_api.SINGLE_PLAYER
        composer.setVariable(game_helpers.START_GAME_FROM_SCENE_KEY, scene.sceneName)
        nav.goToSceneFrom(scene.sceneName, "scenes.create_game_scene", "fade" )
    end
end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.createBackground()
    self.backButton = common_ui.createBackButton(100, 120, "scenes.title_scene", function()
        new_game_data.clearAll()
    end, nil, 2)

    self.randomAiGrp = common_ui.createImageButtonWithText("images/monkey_default.png", "images/monkey_over.png", 225, "Monkey", "(Easy opponent)", getOnReleaseListener(common_api.RANDOM_AI), 300)
    self.bookwormAiGrp = common_ui.createImageButtonWithText("images/bookworm_default.png", "images/bookworm_over.png", 650, "Bookworm", "(Medium opponent)", getOnReleaseListener(common_api.BOOKWORM_AI), 300)
    self.professorAiGrp = common_ui.createImageButtonWithText("images/professor_default.png", "images/professor_over.png", 1075, "Professor", "(Difficult opponent)", getOnReleaseListener(common_api.PROFESSOR_AI), 300)

    sceneGroup:insert(background)
    sceneGroup:insert(self.backButton)
    sceneGroup:insert(self.randomAiGrp)
    sceneGroup:insert(self.bookwormAiGrp)
    sceneGroup:insert(self.professorAiGrp)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        new_game_data.aiType = nil
    elseif ( phase == "did" ) then
        scene_helpers.onDidShowScene(self)

        choose_ai_first_time_tip.new(self):triggerTipOnCondition()
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


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

