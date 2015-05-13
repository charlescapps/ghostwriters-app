local composer = require( "composer" )
local login_common = require("login.login_common")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local widget = require("widget")
local display = require("display")
local native = require("native")
local new_game_data = require("globals.new_game_data")
local current_game = require("globals.current_game")
local game_options_modal = require("classes.game_options_modal")
local create_game_options = require("classes.create_game_options")
local tokens_display = require("classes.tokens_display")
local token_cost_info = require("classes.token_cost_info")

local scene = composer.newScene()
scene.sceneName = "scenes.create_game_scene"

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view

    -- Set the default values for the game density & bonuses layout
    new_game_data.gameDensity = common_api.MEDIUM_DENSITY
    new_game_data.bonusesType = common_api.RANDOM_BONUSES

    self.background = common_ui.createBackground()
    self.gearButton = self:createGearButton()
    self.gameOptionsModal = game_options_modal.new(self)
    self.createGameButton = self:createCreateGameButton()
    self.backButton = common_ui.createBackButton(80, 255, "scenes.choose_board_size_scene")
    self.createGameOptions = create_game_options.new(self:getOnUpdateCostListener())

    sceneGroup:insert(self.background)
    sceneGroup:insert(self.gearButton)
    sceneGroup:insert(self.createGameButton)
    sceneGroup:insert(self.backButton)
    sceneGroup:insert(self.gameOptionsModal:render())
    sceneGroup:insert(self.createGameOptions:render())

    local currentCost = self:getCurrentCost()
    self.tokenCostInfo = token_cost_info.new(display.contentCenterX, 1050, currentCost)
    sceneGroup:insert(self.tokenCostInfo:render())
end

function scene:getOnUpdateCostListener()
    return function()
        local updatedCost = self:getCurrentCost()
        self.tokenCostInfo:updateCost(updatedCost)
    end
end

function scene:getCurrentCost()
    local boardSizeCost = common_api.getTokenCost(new_game_data.boardSize)
    local dictionaryCost = self.createGameOptions:getDictionaryCost()
    return boardSizeCost + dictionaryCost
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

        self.tokensDisplay = tokens_display.new(display.contentCenterX, 120, self.creds.user.tokens)
        sceneGroup:insert(self.tokensDisplay:render())
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        if not self.creds then
            login_common.logout()
            return
        end
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
        self.view = nil
        composer.removeScene(self.sceneName)
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
end

function scene:createGearButton()
    local function onRelease()
        self.gameOptionsModal:show()
    end

    return widget.newButton {
        x = display.contentCenterX + 250,
        y = 1200,
        defaultFile = "images/gear-icon.png",
        overFile = "images/gear-icon_over.png",
        width = 100,
        height = 100,
        onRelease = onRelease
    }
end

function scene:createCreateGameButton()
    local button = common_ui.createButton("Create Game", 1200, self:onReleaseCreateGameButton(), 425)
    button.x = display.contentCenterX - 60
    return button
end

function scene:onReleaseCreateGameButton()
    return function(event)
        local currentScene = composer.getSceneName("current")
        if currentScene == scene.sceneName then
            local newGameModel = new_game_data.getNewGameModel(scene.creds.user)

            if not newGameModel then
                print ("Error - newGameModel not defined: " .. tostring(newGameModel))
                composer.gotoScene("scenes.title_scene")
                return
            end

            -- Create a new game via the API
            common_api.createNewGame(newGameModel, scene.onCreateGameSuccess, scene.onCreateGameFail, nil, true)
        end
    end
end

function scene.onCreateGameSuccess(gameModel)
    local currentScene = composer.getSceneName("current")

    if currentScene == scene.sceneName then
        new_game_data.clearAll()
        current_game.currentGame = gameModel
        composer.gotoScene( "scenes.play_game_scene", "fade" )
    else
        print("ERROR - Attempt to start a new game from create_game_scene, but current scene is now: " .. currentScene)
    end
end

function scene.onCreateGameFail(jsonResp)
    local msg = jsonResp and jsonResp["errorMessage"] or "Network error. Please try again"
    native.showAlert( "Error creating game", msg, { "OK" } )
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

