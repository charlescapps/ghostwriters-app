local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()
local common_ui = require("common.common_ui")

local function createSearchBar() 
    local searchBarGroup = display.newGroup( )
    local title = display.newText( { 
        parent = searchBarGroup, 
        text = "Search for rivals", 
        x = display.contentWidth / 2, 
        y = 150, 
        font = native.systemBoldFont, 
        fontSize = 48
        } )
    title:setFillColor(0, 0, 0)
    local input = native.newTextField( display.contentWidth / 2, 250, 600, 50 )
    input.size = 18
    input.placeholder = "Rival's username"
    input.align = "center"

    local searchIcon = display.newImageRect( searchBarGroup, "images/search-icon.png", 50, 50 )
    searchIcon.x = display.contentWidth / 2 + 325
    searchIcon.y = 250

    local results = native.newTextBox( display.contentWidth / 2, 600, 600, 400 )

    searchBarGroup:insert( input )
    searchBarGroup:insert( results )

    return searchBarGroup

end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    local searchBarGroup = createSearchBar()
    sceneGroup:insert( background )
    sceneGroup:insert( searchBarGroup )
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