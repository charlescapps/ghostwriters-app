local composer = require( "composer" )
local common_ui = require("common.common_ui")
local custom_text_field = require("classes.custom_text_field")
local display = require("display")
local login_common = require("login.login_common")
local scene_helpers = require("common.scene_helpers")

local scene = composer.newScene()

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view

    self.background = common_ui.createBackground()
    self.backButton = self:createBackButton()

    sceneGroup:insert(self.background)
    sceneGroup:insert(self.backButton)

end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
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
        scene_helpers.onWillHideScene(self)
    elseif ( phase == "did" ) then
        self.view = nil
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
end

function scene:createBackButton()
    return common_ui.createBackButton(80, 120, "scenes.title_scene")
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

