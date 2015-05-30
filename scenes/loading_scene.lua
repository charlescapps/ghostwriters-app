local composer = require( "composer" )
local display = require("display")
local main_actions = require("common.main_actions")
local scene = composer.newScene()
scene.sceneName = "scenes.loading_scene"

local BG_WIDTH = 750
local BG_HEIGHT = 1000

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view
    local background = self:createLoadingBackground()
    sceneGroup:insert(background)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        main_actions.getNextUsernameAndLoginIfDeviceFound()
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
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
end

-- Helpers
function scene:createLoadingBackground()
    local width, height = self:computeBgDimensions()
    local img = display.newImageRect("images/LoadingBackground.jpg", width, height)
    img.x = display.contentWidth / 2
    img.y = display.contentHeight / 2
    return img
end

function scene:computeBgDimensions()
    local bgWidth = display.actualContentWidth
    local bgHeight = (bgWidth / BG_WIDTH) * BG_HEIGHT
    return bgWidth, bgHeight
end

function scene:computeBgHeight()

end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

