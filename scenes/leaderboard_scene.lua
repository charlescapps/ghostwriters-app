local composer = require( "composer" )
local common_ui = require("common.common_ui")
local login_common = require("login.login_common")
local leaderboard_class = require("classes.leaderboard_class")
local new_game_data = require("globals.new_game_data")
local common_api = require("common.common_api")
local display = require("display")
local game_helpers = require("common.game_helpers")
local scene_helpers = require("common.scene_helpers")
local ranking_tip = require("tips.ranking_tip")

local scene = composer.newScene()
scene.sceneName = "scenes.leaderboard_scene"

-- "scene:create()"
function scene:create(event)
    self.creds = login_common.fetchCredentials()
    if not self.creds then
        return
    end

    local sceneGroup = self.view
    local background = self:createBackground()

    local function onLoadSuccess()
        ranking_tip.new():triggerTipOnCondition()
    end

    local function onLoadFail()
        composer.gotoScene("scenes.title_scene", "fade")
    end

    self.leaderboard = leaderboard_class.new(self, self.creds.user, onLoadSuccess, onLoadFail)
    local leaderboardView = self.leaderboard:render()
    self.backButton = common_ui.createBackButton(80, 80, "scenes.title_scene", nil, nil, 3)

    sceneGroup:insert(background)
    sceneGroup:insert(leaderboardView)
    sceneGroup:insert(self.backButton)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        if not self.creds then
            return
        end
        self.leaderboard:loadRanksNearUser(self.creds.user.id)

    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
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
        -- Called when the scene is on screen (but is about to go off screen).
        if self.userInfoPopup then
            self.userInfoPopup:destroy()
        end
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
        self.view = nil
        composer.removeScene(self.sceneName, false)
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
end

function scene:startGameWithUser(userModel)
    local currentScene = composer.getSceneName("current")
    if currentScene == self.sceneName and userModel.id ~= scene.creds.user.id then
        new_game_data.clearAll()
        new_game_data.rival = userModel
        new_game_data.gameType = common_api.TWO_PLAYER
        composer.setVariable(game_helpers.START_GAME_FROM_SCENE_KEY, self.sceneName)
        composer.gotoScene("scenes.choose_board_size_scene", "fade")
    end
end

function scene:createBackground()
    local img = display.newImageRect("images/old_book.png", 1350, 1948)
    img.x = display.contentWidth / 2
    img.y = display.contentHeight / 2
    return img
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene