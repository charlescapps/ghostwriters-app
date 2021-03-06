local composer = require( "composer" )
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local new_game_data = require("globals.new_game_data")
local native = require("native")
local login_common = require("login.login_common")
local user_search_widget = require("classes.user_search_widget")
local user_info_popup = require("classes.user_info_popup")
local game_helpers = require("common.game_helpers")
local widget = require("widget")
local display = require("display")
local imgs = require("globals.imgs")
local scene_helpers = require("common.scene_helpers")
local challenged_popup = require("classes.challenged_popup")

local scene = composer.newScene()
scene.sceneName = "scenes.start_multiplayer_scene"

-- Constants
local SEARCH_BOX_WIDTH = 450
local SEARCH_BOX_HEIGHT = 480
local MARGIN = 25

-- "scene:create()"
function scene:create(event)
    self.creds = login_common.fetchCredentials()
    if not self.creds then
        return
    end

    local sceneGroup = self.view
    self.background = common_ui.createBackground()

    self.quickStartButton = self:createQuickStartButton()

    self.backButton = common_ui.createBackButton(50, 120, "scenes.title_scene", nil, nil, 2)

    self.userSearchWidget = user_search_widget.new(self.creds.user, MARGIN, 400, SEARCH_BOX_WIDTH, SEARCH_BOX_HEIGHT,
        self:getOnRowTouchListener())

    sceneGroup:insert(self.background)

    sceneGroup:insert(self.quickStartButton)
    sceneGroup:insert(self.backButton)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        if not self.creds then
            return
        end
        sceneGroup:insert(self.userSearchWidget:render())
        self.userSearchWidget:queryForUsersWithSimilarRating()
    elseif ( phase == "did" ) then
        if not self.creds then
            login_common.logout()
            return
        end
        scene_helpers.onDidShowScene(self)
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        scene_helpers.onWillHideScene()
        if self.userSearchWidget then
            self.userSearchWidget:destroy()
        end
        if self.userInfoPopup then
            self.userInfoPopup:destroy()
        end
    elseif ( phase == "did" ) then
        self.view = nil
        composer.removeScene(self.sceneName, false)
    end
end


-- "scene:destroy()"
function scene:destroy( event )

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
        composer.setVariable(game_helpers.START_GAME_FROM_SCENE_KEY, self.sceneName)

        composer.gotoScene("scenes.create_game_scene", "fade")

        local challengedPopup = challenged_popup.new(userModel, nil)
        challengedPopup:show()

    end
end

function scene:openUserInfoPopup(user)
    local onDestroyPopup = function()
        local currentScene = composer.getSceneName("current")
        if currentScene == self.sceneName then
           if self.userSearchWidget then
               self.userSearchWidget:showNativeInput()
           end
        end
    end
    self.userInfoPopup = user_info_popup.new(user, self, self.creds.user, true, onDestroyPopup)
    self.view:insert(self.userInfoPopup:render())
end

function scene:getOnRowTouchListener()
    return function(user)
        self.userSearchWidget:hideNativeInput()
        self:openUserInfoPopup(user)
    end
end

function scene:createQuickStartButton()
    local button = widget.newButton {
        width = imgs.QUICKSTART_BUTTON_WIDTH,
        height = imgs.QUICKSTART_BUTTON_HEIGHT,
        defaultFile = imgs.QUICKSTART_BUTTON_DEFAULT,
        overFile = imgs.QUICKSTART_BUTTON_OVER,
        onRelease = self:getOnReleaseStartGameListener()
    }
    button.x = display.contentWidth / 2
    button.y = 225
    return button
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

