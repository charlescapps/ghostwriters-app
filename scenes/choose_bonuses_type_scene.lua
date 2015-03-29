local composer = require( "composer" )
local nav = require("common.nav")
local login_common = require("login.login_common")
local common_api = require( "common.common_api" )
local common_ui = require( "common.common_ui" )
local new_game_data = require("globals.new_game_data")
local current_game = require("globals.current_game")
local scene = composer.newScene()

scene.sceneName = "scenes.choose_bonuses_type_scene"

local function onCreateGameSuccess(gameModel)

    local currentScene = composer.getSceneName("current")

    if currentScene == scene.sceneName then
        new_game_data.clearAll()
        current_game.currentGame = gameModel
        composer.gotoScene( "scenes.play_game_scene", "fade" )
    else
        print("ERROR - Attempt to start a new game from choose_bonuses_type_scene, but current scene is now: " .. currentScene)
    end

end

local function onCreateGameFail(jsonResp)
    local msg = jsonResp["errorMessage"] or "Network error. Please try again"
    native.showAlert( "Error creating game", msg, { "OK" } )
end

local function getOnReleaseListener(bonusesType)
    return function(event)
        -- Only perform action if we are still on the choose bonuses scene.
        local currentScene = composer.getSceneName("current")
        if currentScene == scene.sceneName then
            new_game_data.bonusesType = bonusesType
            local newGameModel = new_game_data.getNewGameModel(scene.creds.user)

            if not newGameModel then
                print ("Error creating new game model from new_game_data module")
                native.showAlert( "Error", "Error creating a new game, please try again", { "OK" } )
                composer.gotoScene("scenes.title_scene")
                return
            end

            -- Create a new game via the API
            common_api.createNewGame(newGameModel, onCreateGameSuccess, onCreateGameFail, nil, true)
        end
    end

end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.createBackground()
    local backButton = common_ui.createBackButton(100, 100, "scenes.choose_game_density_scene", function()
        new_game_data.bonusesType, new_game_data.gameDensity = nil, nil
    end)

    local smallBoardGrp = common_ui.createImageButtonWithText("images/fixed_bonuses.jpg", "images/fixed_bonuses_dark.jpg", 300, "Standard bonuses", "(Same bonus squares every time)", getOnReleaseListener(common_api.FIXED_BONUSES))
    local mediumBoardGrp = common_ui.createImageButtonWithText("images/random_bonuses.jpg", "images/random_bonuses_dark.jpg", 800, "Random bonuses", "(Unpredictable bonus squares)", getOnReleaseListener(common_api.RANDOM_BONUSES))

    sceneGroup:insert(background)
    sceneGroup:insert(backButton)
    sceneGroup:insert(smallBoardGrp)
    sceneGroup:insert(mediumBoardGrp)
end

-- "scene:show()"
function scene:show( event )

    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        new_game_data.bonusesType = nil

        self.creds = login_common.fetchCredentials()
        if not self.creds then
            login_common.dumpToLoggedOutScene(self.sceneName)
            return
        end

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


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

