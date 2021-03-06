local composer = require( "composer" )
local login_common = require("login.login_common")
local my_challengers_view_class = require("classes.my_challengers_view_class")
local new_game_data = require("globals.new_game_data")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local game_helpers = require("common.game_helpers")
local scene_helpers = require("common.scene_helpers")
local challenged_popup = require("classes.challenged_popup")

local scene = composer.newScene()
scene.sceneName = "scenes.my_challengers_scene"

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view
    local background = common_ui.createBackground()
    self.backButton = common_ui.createBackButton(80, 100, "scenes.title_scene")
    sceneGroup:insert(background)
    sceneGroup:insert(self.backButton)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        self.creds = login_common.fetchCredentials()
        if not self.creds then
            return
        end

    elseif ( phase == "did" ) then
        if not self.creds then
           login_common.logout()
           return
        end

        self:createMyGamesViewAndQuery(self.creds.user)

        scene_helpers.onDidShowScene(self)
    end
end

function scene:getRefreshGamesCallback()
    return function()
        if self.creds and self.creds.user then
            self:createMyGamesViewAndQuery(self.creds.user)
        end
    end
end

function scene:createMyGamesViewAndQuery(user)

    if self.myChallengersView then
        self.myChallengersView:destroy()
    end

    self.myChallengersView = my_challengers_view_class.new(user, true, self, self:getRefreshGamesCallback())

    common_api.getGamesOfferedToMe(common_api.COUNT_PER_PAGE, nil, self:getOnSuccessCallback(), self:getOnFailCallback(), self:getOnFailCallback(), true)

end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        scene_helpers.onWillHideScene()
    elseif ( phase == "did" ) then
        if self.myChallengersView then
            self.myChallengersView:destroy()
            self.myChallengersView = nil
        end
        -- Called immediately after scene goes off screen.
        self.view = nil
        composer.removeScene(self.sceneName, false)
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view
    if self.myChallengersView then
        self.myChallengersView:destroy()
    end
end

function scene:getOnSuccessCallback()
    return function(games)
        if not games or not games.list then
            print("The games endpoint returned nil or is missing the 'list' field: " .. tostring(games))
            common_ui.createInfoModal("Oops...", "A network error occurred. Please try again.")
           return
        end
        self.myChallengersView:setGames(games)
        local tableView = self.myChallengersView:render()
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

        local function onClose()
            composer.gotoScene("scenes.title_scene", "fade")
        end

        common_ui.createInfoModal("Oops...", errorMessage, onClose)

    end
end

function scene:startGameWithUser(userModel)
    local currentScene = composer.getSceneName("current")
    if currentScene == self.sceneName and userModel.id ~= scene.creds.user.id then
        new_game_data.clearAll()
        new_game_data.rival = userModel
        new_game_data.gameType = common_api.TWO_PLAYER
        composer.setVariable(game_helpers.START_GAME_FROM_SCENE_KEY, self.sceneName)
        composer.gotoScene("scenes.create_game_scene", "fade")

        local challengedPopup = challenged_popup.new(userModel)
        challengedPopup:show()
    end
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene


