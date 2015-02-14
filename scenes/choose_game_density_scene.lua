local composer = require( "composer" )
local widget = require( "widget" )
local common_api = require( "common.common_api" )
local common_ui = require( "common.common_ui" )
local new_game_data = require("globals.new_game_data")
local scene = composer.newScene()

local function onPress()
    print ("Pressed button")
end

local function getOnReleaseListener(gameDensity)
    return function(event)
        new_game_data.gameDensity = gameDensity
        composer.gotoScene( "scenes.choose_bonuses_type_scene", "fade" )
    end

end


-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    sceneGroup:insert(background)

    local smallBoardGrp = common_ui.create_img_button_group("images/sparse.jpg", "images/sparse_dark.jpg", 200, "Sparse", "(9-15 words)", onPress, getOnReleaseListener(common_api.LOW_DENSITY))
    local mediumBoardGrp = common_ui.create_img_button_group("images/regular_density.jpg", "images/regular_density_dark.jpg", 600, "Regular", "(12-18 words)", onPress, getOnReleaseListener(common_api.MEDIUM_DENSITY))
    local largeBoardGrp = common_ui.create_img_button_group("images/word_jungle.jpg", "images/word_jungle_dark.jpg", 1000, "Word Jungle", "(15-21 words)", onPress, getOnReleaseListener(common_api.HIGH_DENSITY))

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

