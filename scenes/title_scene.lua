local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()


buttonSinglePlayer = nil
buttonPlayOthers = nil
buttonFacebook = nil

local function create_title_button(text, id, y)
	button = widget.newButton( {
		id = id,
		x = display.contentWidth / 2,
		y = y,
		emboss = true,
		label = text,
		fontSize = 44,
		labelColor = { default = {1, 0.9, 0.9}, over = { 0, 0, 0 } },
		width = 500,
		height = 125,
		shape = "roundedRect",
		cornerRadius = 15,
		fillColor = { default={ 0.93, 0.48, 0.01, 0.7 }, over={ 0.76, 0, 0.13, 1 } },
		strokeColor = { 1, 0.2, 0.2 },
		strokeRadius = 10
		} )
	return button
end

local click_single_player = function()
	 print( "foo" )
end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
	titleText = display.newText( "Words with Rivals", display.contentWidth / 2, 150, "Arial", 64 )
	buttonSinglePlayer = create_title_button("Single Player", "single_player_button", 400)
	buttonPlayOthers = create_title_button("Play with rivals", "multi_player_button", 700)
	buttonFacebook = create_title_button("Find rivals on Facebook", "facebook_button", 1000)

	sceneGroup:insert( titleText )
	sceneGroup:insert( buttonSinglePlayer )
	sceneGroup:insert( buttonPlayOthers )
	sceneGroup:insert( buttonFacebook )
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

