local composer = require( "composer" )
local common_ui = require("common.common_ui")
local credits_widget = require("classes.credits_widget")
local scene = composer.newScene()
local scene_helpers = require("common.scene_helpers")

scene.sceneName = "scenes.credits_scene"

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view
    self.creditsWidget = credits_widget.new()
    sceneGroup:insert(self.creditsWidget:render())

    self.backButton = common_ui.createBackButton(80, 110, "scenes.title_scene", nil, nil, 3)

    sceneGroup:insert(self.backButton)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        scene_helpers.onDidShowScene(self)
        self.creditsWidget:animateCredits()
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        scene_helpers.onWillHideScene()
        if self.creditsWidget then
            self.creditsWidget:cancelActiveTimer()
        end
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

