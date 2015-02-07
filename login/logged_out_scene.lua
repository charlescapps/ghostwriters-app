local composer = require( "composer" )
local widget = require( "widget" )
local common_ui = require("common.common_ui")
local scene = composer.newScene()

local function create_button_new_account()
    return common_ui.create_button("Create a new user", "new_account_button", 350, 
        function() 
            composer.gotoScene( "login.create_account_scene" , "fade" )
            scene:destroy()
        end )
end

local function create_button_sign_in()
    return common_ui.create_button("Sign in", "sign_in_button", 550)
end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    local title = common_ui.create_title("Words with Rivals", nil, { 0, 0, 0})
    local button_new_account = create_button_new_account()
    local button_sign_in = create_button_sign_in()

    sceneGroup:insert(background)
    sceneGroup:insert(title)    
    sceneGroup:insert(button_new_account)
    sceneGroup:insert(button_sign_in)

end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

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