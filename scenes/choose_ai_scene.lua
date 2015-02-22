local composer = require( "composer" )
local widget = require( "widget" )
local common_api = require( "common.common_api" )
local common_ui = require( "common.common_ui" )
local new_game_data = require("globals.new_game_data")
local scene = composer.newScene()

local function getOnReleaseListener(aiType)
    return function(event)
        new_game_data.aiType = aiType
        composer.gotoScene( "scenes.choose_board_size_scene", "fade" )
    end

end


-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    sceneGroup:insert(background)

    local randomAiGrp = common_ui.create_img_button_group("images/monkey-typing.jpg", "images/monkey-typing-dark.jpg", 200, "Monkey", "(Random opponent)", nil, getOnReleaseListener(common_api.RANDOM_AI))
    local bookwormAiGrp = common_ui.create_img_button_group("images/bookworm.jpg", "images/bookworm-dark.jpg", 600, "Bookworm", "(Normal opponent)", nil, getOnReleaseListener(common_api.BOOKWORM_AI))
    local professorAiGrp = common_ui.create_img_button_group("images/professor.jpeg", "images/professor-dark.jpeg", 1000, "Professor", "(Difficult opponent)", nil, getOnReleaseListener(common_api.PROFESSOR_AI))

    sceneGroup:insert(randomAiGrp)
    sceneGroup:insert(bookwormAiGrp)
    sceneGroup:insert(professorAiGrp)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phases

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
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

