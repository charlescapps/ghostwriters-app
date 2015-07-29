local composer = require( "composer" )
local login_common = require("login.login_common")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local current_game = require("globals.current_game")
local dict_controller = require("classes.dict_controller")
local native = require("native")
local scene_helpers = require("common.scene_helpers")

local scene = composer.newScene()

scene.sceneName = "scenes.dictionary_scene"

-- "scene:create()"
function scene:create(event)
    self.creds = login_common.fetchCredentials()
    if not self.creds then
        return
    end
    self.background = common_ui.createBackground()
    self.backButton = common_ui.createBackButton(80, 80, "scenes.play_game_scene")

    self.view:insert(self.background)
    self.view:insert(self.backButton)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        if not self.creds or not current_game.currentGame then
            return
        end
        local specialDict = current_game.currentGame.specialDict
        if not specialDict then
            -- Display message for English Dictionary (no special dict)
            -- Or, have a popup when the user first presses the Dictionary button.

            return
        end

        local function onSuccess(dict)
            self.dictController = dict_controller.new(self, dict)
            self.dictController:render()
        end

        local function onFail()
            local function onClose()
                composer.gotoScene("scenes.play_game_scene", "fade")
            end

            common_ui.createInfoModal("Network Error", "Please try again.", onClose)
        end

        common_api.getDictionary(specialDict, onSuccess, onFail, true)

    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        if not self.creds or not current_game.currentGame then
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
        -- Called when the scene is on screen (but is about to go off screen).
        scene_helpers.onWillHideScene()
    elseif ( phase == "did" ) then
        -- Set self.view to nil, so that create() will be called each time we load this scene.
        self.view = nil
        composer.removeScene(self.sceneName, false)
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

