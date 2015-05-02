local composer = require( "composer" )
local display = require("display")
local slidey_bookmark = require("classes.slidey_bookmark")
local login_common = require( "login.login_common" )
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local scene = composer.newScene()
local json = require("json")
local new_game_data = require("globals.new_game_data")
local nav = require("common.nav")

-- Constants
scene.sceneName = "scenes.title_scene"


local clickSinglePlayer = function()
	print("Clicked single player")
	new_game_data.clearAll()
	new_game_data.gameType = common_api.SINGLE_PLAYER
    nav.goToSceneFrom(scene.sceneName, "scenes.choose_ai_scene", "fade")
end

local clickOneOnOne = function()
	 print( "Clicked play with rivals" )
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

        print("Found numGamesMyTurn=" .. numGamesMyTurn)
        print("Found numGamesOffered=" .. numGamesOffered)

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
    common_api.getMyGamesSummary(self:onFetchGameSummarySuccess(), self:onFetchGameSummaryFail(), false)
end

-- "scene:create()"
function scene:create(event)

	local sceneGroup = self.view
	local background = common_ui.createBackground()
	local titleImage = self:createTitleImage()
	local buttonSinglePlayer = common_ui.createButton("Single Player", 350, clickSinglePlayer)
	local buttonPlayOthers = common_ui.createButton("Two Player", 550, clickOneOnOne)
	local buttonMyGames = common_ui.createButton("My Games", 750, clickMyGames)
	local buttonMyChallengers = common_ui.createButton("My Challengers", 950, clickMyChallengers)
	local buttonLeaderboard = common_ui.createButton("Leaderboard", 1150, clickLeaderboard)

	sceneGroup:insert( background )
	sceneGroup:insert(titleImage)
	sceneGroup:insert( buttonSinglePlayer )
	sceneGroup:insert( buttonPlayOthers )
	sceneGroup:insert( buttonMyGames )
	sceneGroup:insert( buttonMyChallengers )
    sceneGroup:insert( buttonLeaderboard )
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

        print("Logged in as=" .. json.encode( self.creds.user ))

        if self.userInfoText then
            self.userInfoText:removeSelf()
        end
        self.userInfoText = self:createUserInfoText()
        sceneGroup:insert(self.userInfoText)

        self:fetchGameSummaryInfo()

    elseif ( phase == "did" ) then
        if not self.creds then
            login_common.logout()
        end
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

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
        font = native.systemFontBold,
        fontSize = 48,
        x = display.contentWidth / 2,
        y = 225,
        align = "center"
    }
    userInfoText:setFillColor(0, 0, 0)
    return userInfoText
end

function scene:addNumGamesMyTurnBookmark(num)

end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

