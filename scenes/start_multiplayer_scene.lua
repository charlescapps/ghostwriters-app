local composer = require( "composer" )
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local new_game_data = require("globals.new_game_data")
local native = require("native")
local login_common = require("login.login_common")
local user_search_widget = require("classes.user_search_widget")
local user_info_popup = require("classes.user_info_popup")
local scene = composer.newScene()
scene.sceneName = "scenes.start_multiplayer_scene"

-- Constants
local SEARCH_BOX_WIDTH = 700
local SEARCH_BOX_HEIGHT = 800
local MARGIN = 25

-- "scene:create()"
function scene:create(event)
    self.creds = login_common.fetchCredentialsOrLogout()
    if not self.creds then
        return
    end

    local sceneGroup = self.view
    self.background = common_ui.createBackground()

    self.startGameButton = common_ui.createBookButton("Start a game", "Play a Ghostwriter of similar skill", nil,
        self:getOnReleaseStartGameListener(), nil, 225)

    self.backButton = common_ui.createBackButton(50, 100, "scenes.title_scene")

    self.userSearchWidget = user_search_widget.new(self.creds.user, MARGIN, 400, SEARCH_BOX_WIDTH, SEARCH_BOX_HEIGHT,
        self:getOnRowTouchListener())

    sceneGroup:insert(self.background)

    sceneGroup:insert(self.startGameButton)
    sceneGroup:insert(self.backButton)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        sceneGroup:insert(self.userSearchWidget:render())
        self.userSearchWidget:queryForUsersWithSimilarRating()
    elseif ( phase == "did" ) then

    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        if self.userSearchWidget then
            self.userSearchWidget:destroy()
        end
        if self.userInfoPopup then
            self.userInfoPopup:destroy()
        end
    elseif ( phase == "did" ) then

    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view
    sceneGroup:removeSelf()

end

function scene:getOnReleaseStartGameListener()
    return function()
        common_api.getBestMatch(function(user)
            self:startGameWithUser(user)
        end,
        function()
            native.showAlert("Network Error", "A network error occurred", { "Try again" })
        end)
    end
end

function scene:startGameWithUser(userModel)
    local currentScene = composer.getSceneName("current")
    if currentScene == self.sceneName and userModel.id ~= scene.creds.user.id then
        new_game_data.clearAll()
        new_game_data.rival = userModel
        new_game_data.gameType = common_api.TWO_PLAYER
        composer.gotoScene("scenes.choose_board_size_scene", "fade")
    end
end

function scene:openUserInfoPopup(user)
    self.userInfoPopup = user_info_popup.new(user, self, self.creds.user, true)
    self.view:insert(self.userInfoPopup:render())
end

function scene:getOnRowTouchListener()
    return function(user)
        self:openUserInfoPopup(user)
    end
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

