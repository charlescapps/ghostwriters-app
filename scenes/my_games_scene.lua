local composer = require( "composer" )
local login_common = require("login.login_common")
local my_games_view_class = require("classes.my_games_view_class")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")

local scene = composer.newScene()
scene.sceneName = "scenes.my_games_scene"

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view
    local background = common_ui.create_background()
    self.backButton = common_ui.create_back_button(100, 100, "scenes.title_scene", function()
        print("Before transition")
    end)
    sceneGroup:insert(background)
    sceneGroup:insert(self.backButton)
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
        self.myGamesView = my_games_view_class.new(user)

        common_api.getMyGames(user.id, common_api.MAX_GAMES_IN_PROGRESS, true, self:getOnSuccessCallback(), self:getOnFailCallback(), self:getOnFailCallback(), true)

    elseif ( phase == "did" ) then

    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
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

        common_ui.create_info_modal("Oops...", errorMessage)

    end
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene


