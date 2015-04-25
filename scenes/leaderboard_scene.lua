local composer = require( "composer" )
local common_ui = require("common.common_ui")
local login_common = require("login.login_common")
local leaderboard_class = require("classes.leaderboard_class")

local scene = composer.newScene()
scene.sceneName = "scenes.leaderboard_scene"

-- "scene:create()"
function scene:create(event)
    self.creds = login_common.fetchCredentials()
    if not self.creds then
        return
    end

    local sceneGroup = self.view
    local background = common_ui.createBackground()
    self.leaderboard = leaderboard_class.new()
    local leaderboardView = self.leaderboard:render()

    sceneGroup:insert(background)
    sceneGroup:insert(leaderboardView)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        if not self.creds then
            return
        end
        self.leaderboard:loadRanksNearUser(self.creds.user)

    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        if not self.creds then
            login_common.logout()
            return
        end
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
        if not self.creds then
            self.view = nil
            composer.removeScene(self.sceneName, false)
        end
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

