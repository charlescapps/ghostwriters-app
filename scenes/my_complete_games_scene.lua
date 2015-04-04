local composer = require( "composer" )
local display = require("display")
local widget = require("widget")
local nav = require("common.nav")
local login_common = require("login.login_common")
local my_games_view_class = require("classes.my_games_view_class")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")

local scene = composer.newScene()
scene.sceneName = "scenes.my_complete_games_scene"

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view
    local background = common_ui.createBackground()
    self.backButton = common_ui.createBackButton(80, 80, "scenes.title_scene")
    self.goToActiveGamesButton = self:createGoToActiveGamesButton()
    sceneGroup:insert(background)
    sceneGroup:insert(self.backButton)
    sceneGroup:insert(self.goToActiveGamesButton)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        local creds = login_common.fetchCredentials()
        if not creds then
            login_common.dumpToLoggedOutScene(self.sceneName)
            return
        end
        self.creds = creds
        local user = creds.user
        self.myGamesView = my_games_view_class.new(user, false, self)

        common_api.getMyGames(common_api.MAX_GAMES_IN_PROGRESS, false, self:getOnSuccessCallback(), self:getOnFailCallback(), self:getOnFailCallback(), true)

    elseif ( phase == "did" ) then

    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        if self.myGamesView then
            self.myGamesView:destroy()
            self.myGamesView = nil
        end
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view
    if self.myGamesView then
        self.myGamesView:destroy()
    end
end

function scene:getOnSuccessCallback()
    return function(games)
        if not games or not games.list then
            print("The games endpoint returned nil or is missing the 'list' field: " .. tostring(games))
            common_ui.createInfoModal("Oops...", "A network error occurred. Please try again.")
           return
        end
        self.myGamesView:setGames(games)
        local tableView = self.myGamesView:render()
        self.view:insert(tableView)
        self.backButton:toFront()
    end
end

function scene:getOnFailCallback()
    return function(errorJson)
        local errorMessage
        if errorJson and errorJson.errorMessage and errorJson.errorMessage:len() > 0 then
            errorMessage = errorJson.errorMessage
        else
            errorMessage = "A network error occurred. Please try again."
        end

        common_ui.createInfoModal("Oops...", errorMessage)

    end
end

function scene:createGoToActiveGamesButton()
    local label = self:getGoToActiveGamesButtonText()

    local button = widget.newButton( {
        x = display.contentWidth - 100,
        y = 100,
        emboss = true,
        label = label,
        fontSize = 36,
        labelColor = { default = {1, 0.9, 0.9}, over = { 0, 0, 0 } },
        width = 175,
        height = 100,
        shape = "roundedRect",
        cornerRadius = 15,
        fillColor = { default={ 0.93, 0.48, 0.01, 0.7 }, over={ 0.76, 0, 0.13, 1 } },
        strokeColor = { 1, 0.2, 0.2 },
        strokeRadius = 10,
        onRelease = self:getOnReleaseGoToActiveGamesButton()
    } )
    return button
end

function scene:getGoToActiveGamesButtonText()
    return "Active"
end

function scene:getOnReleaseGoToActiveGamesButton()
    return function(event)
        nav.goToSceneFrom(self.sceneName, "scenes.my_active_games_scene")
    end
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene


