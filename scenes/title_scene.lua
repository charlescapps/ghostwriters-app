local composer = require( "composer" )
local display = require("display")
local widget = require( "widget" )
local login_common = require( "login.login_common" )
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local scene = composer.newScene()
local json = require("json")
local new_game_data = require("globals.new_game_data")
local nav = require("common.nav")

-- Constants
scene.sceneName = "scenes.title_scene"

-- Pre-defined functions
local createTitleButton
local createTitleText
local createUserInfoText


local click_single_player = function()
	print("Clicked single player")
	new_game_data.clearAll()
	new_game_data.gameType = common_api.SINGLE_PLAYER
    nav.goToSceneFrom(scene.sceneName, "scenes.choose_ai_scene", "fade")
end

local click_play_others = function()
	 print( "Clicked play with rivals" )
	 new_game_data.clearAll()
	 new_game_data.gameType = common_api.TWO_PLAYER
     nav.goToSceneFrom(scene.sceneName, "scenes.search_for_opponent_scene", "fade")
end

-- "scene:create()"
function scene:create(event)

	local sceneGroup = self.view
	local background = common_ui.create_background()
	local titleText = createTitleText()
	local buttonSinglePlayer = createTitleButton("Single Player", "single_player_button", 400, click_single_player)
	local buttonPlayOthers = createTitleButton("Play with rivals", "multi_player_button", 700, click_play_others)
	local buttonFacebook = createTitleButton("Find rivals on Facebook", "facebook_button", 1000)

	sceneGroup:insert(background)
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
        self.creds = login_common.fetchCredentials()

        if not self.creds then
            login_common.dumpToLoggedOutScene(self.sceneName)
            return
        end

        print("Logged in as=" .. json.encode( self.creds.user ))

        local userInfoText = createUserInfoText()
        sceneGroup:insert(userInfoText)

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

-- Local helpers
createTitleText = function()
    local titleText = display.newText( "Ghost Writers", display.contentWidth / 2, 150, "Arial", 64 )
    titleText:setFillColor(0, 0, 0)
    return titleText
end

createUserInfoText = function()
    local username = scene.creds.user.username
    local userInfoText = display.newText {
        text = username,
        font = native.systemFontBold,
        fontSize = 48,
        x = display.contentWidth / 2,
        y = 225,
        align = "center"
    }
    userInfoText:setFillColor(0, 0, 0)
    return userInfoText
end

createTitleButton = function(text, id, y, onRelease)
    return widget.newButton( {
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
        strokeRadius = 10,
        onRelease = onRelease
    } )
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

