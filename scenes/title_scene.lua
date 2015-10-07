local composer = require( "composer" )
local display = require("display")
local slidey_bookmark = require("classes.slidey_bookmark")
local login_common = require( "login.login_common" )
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local new_game_data = require("globals.new_game_data")
local nav = require("common.nav")
local app_state = require("globals.app_state")
local fonts = require("globals.fonts")
local scene_helpers = require("common.scene_helpers")
local widget = require("widget")
local user_options_menu = require("classes.user_options_menu")
local back_button_setup = require("android.back_button_setup")
local music = require("common.music")
local sound = require("common.sound")
local fb = require("social.fb")

-- Constants
local scene = composer.newScene()
scene.sceneName = "scenes.title_scene"


local clickSinglePlayer = function()
	print("Clicked single player")
	new_game_data.clearAll()
	new_game_data.gameType = common_api.SINGLE_PLAYER
    nav.goToSceneFrom(scene.sceneName, "scenes.choose_ai_scene", "fade")
end

local clickOneOnOne = function()
	 print("Clicked Two Player")
	 new_game_data.clearAll()
	 new_game_data.gameType = common_api.TWO_PLAYER
     nav.goToSceneFrom(scene.sceneName, "scenes.start_multiplayer_scene", "fade")
end

local clickMyGames = function()
    print( "Clicked My Games" )
    nav.goToSceneFrom(scene.sceneName, "scenes.my_active_games_scene", "fade")
end

local clickMyChallengers = function()
    print( "Clicked My Challengers" )
    nav.goToSceneFrom(scene.sceneName, "scenes.my_challengers_scene", "fade")
end

local clickLeaderboard = function()
    print( "Clicked Leaderboard" )
    nav.goToSceneFrom(scene.sceneName, "scenes.leaderboard_scene", "fade")
end

function scene:onFetchGameSummarySuccess()
    return function(summary)
        if not summary then
            print("Error - no summary returned from server!")
            return
        end
        local numGamesMyTurn = summary.numGamesMyTurn
        local numGamesOffered = summary.numGamesOffered

        print("Found numGamesMyTurn=" .. tostring(numGamesMyTurn))
        print("Found numGamesOffered=" .. tostring(numGamesOffered))

        self.myTurnGamesBookmark = slidey_bookmark.new(numGamesMyTurn, 1, 750)
        self.offeredGamesBookmark = slidey_bookmark.new(numGamesOffered, 2, 950)
        self.view:insert(self.myTurnGamesBookmark:render())
        self.view:insert(self.offeredGamesBookmark:render())

        self.myTurnGamesBookmark:slideIn()
        self.offeredGamesBookmark:slideIn()
    end
end

function scene:onFetchGameSummaryFail()
    return function()
        -- Silently fail
        print("ERROR - couldn't get game summary info. Not displaying bookmarks")
    end
end

function scene:fetchGameSummaryInfo()
    if self.myTurnGamesBookmark then
        return
    end
    common_api.getMyGamesSummary(self:onFetchGameSummarySuccess(), self:onFetchGameSummaryFail(), false)
end

function scene:createFacebookButton()
    local function onRelease()
        fb.loginToFacebook(function()
            fb.shareToFacebook()
        end)
    end

    local button = widget.newButton {
        defaultFile = "images/facebook_button.png",
        overFile = "images/facebook_button_over.png",
        width = 150,
        height = 52,
        x = 90,
        y = 550,
        onRelease = onRelease
    }

    return button
end

-- "scene:create()"
function scene:create(event)

    local BUTTON_W = 400

	local sceneGroup = self.view
	local background = common_ui.createBackground()
	local titleImage = self:createTitleImage()
	local buttonSinglePlayer = common_ui.createButton("Single Player", 350, clickSinglePlayer, BUTTON_W)
	local buttonPlayOthers = common_ui.createButton("Two Player", 550, clickOneOnOne, BUTTON_W)
    local buttonFacebook = self:createFacebookButton()
	local buttonMyGames = common_ui.createButton("My Games", 750, clickMyGames, BUTTON_W)
	local buttonMyChallengers = common_ui.createButton("My Challengers", 950, clickMyChallengers, BUTTON_W)
	local buttonLeaderboard = common_ui.createButton("Leaderboard", 1150, clickLeaderboard, BUTTON_W)
    self.userOptionsButton = self:createUserOptionsButton()
    self.creditsButton = self:createCreditsButton()

	sceneGroup:insert( background )
	sceneGroup:insert( titleImage )
	sceneGroup:insert( buttonSinglePlayer )
	sceneGroup:insert( buttonPlayOthers )
    sceneGroup:insert(buttonFacebook)
	sceneGroup:insert( buttonMyGames )
	sceneGroup:insert( buttonMyChallengers )
    sceneGroup:insert( buttonLeaderboard )
    sceneGroup:insert( self.userOptionsButton )
    sceneGroup:insert( self.creditsButton )
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        self.creds = login_common.fetchCredentials()

        if not self.creds then
            return
        end

        music.playTitleMusic()

        -- Fetch num games where it's your turn / num challengers to display on info bookmarks
        self:fetchGameSummaryInfo()

        if self.userInfoText then
            self.userInfoText:removeSelf()
        end
        self.userInfoText = self:createUserInfoText()
        sceneGroup:insert(self.userInfoText)

    elseif ( phase == "did" ) then
        if not self.creds then
            login_common.logout()
        end

        back_button_setup.setBackListenerToExitApp()

        app_state:setAppLoaded()
        app_state:callAppLoadedListener()

    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        scene_helpers.onWillHideScene()
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
        self.view = nil
        composer.removeScene(self.sceneName, false)
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

end

-- Local helpers
function scene:createTitleImage()
    local titleImg = display.newImageRect( "images/ghostwriters_title.png", display.contentWidth, 175)
    titleImg.x = display.contentWidth / 2
    titleImg.y = 125
    return titleImg
end

function scene:createUserInfoText()
    local username = scene.creds.user.username
    local userInfoText = display.newText {
        text = username,
        font = fonts.BOLD_FONT,
        fontSize = 48,
        x = display.contentWidth / 2,
        y = 225,
        align = "center"
    }
    userInfoText:setFillColor(0, 0, 0)
    return userInfoText
end

function scene:createUserOptionsButton()
    local function onRelease()
        local userOptionsMenu = user_options_menu.new()
        self.view:insert(userOptionsMenu:render())
        userOptionsMenu:show()
    end

    return widget.newButton {
        x = display.contentWidth - 80,
        y = display.contentHeight - 80,
        defaultFile = "images/gear-icon.png",
        overFile = "images/gear-icon_over.png",
        width = 125,
        height = 125,
        onRelease = onRelease
    }
end

function scene:createCreditsButton()
    local function onRelease()
        sound.playPageFlip()
        composer.gotoScene("scenes.credits_scene", "fade")
    end

    return widget.newButton {
        x = 80,
        y = display.contentHeight - 80,
        defaultFile = "images/credits_button_default.png",
        overFile = "images/credits_button_over.png",
        width = 125,
        height = 125,
        onRelease = onRelease
    }
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

