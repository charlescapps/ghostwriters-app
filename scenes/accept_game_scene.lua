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
local pay_helpers = require("common.pay_helpers")
local purchase_store = require("common.purchase_store")
local json = require("json")
local scene_helpers = require("common.scene_helpers")
local fonts = require("globals.fonts")

local scene = composer.newScene()
scene.sceneName = "scenes.accept_game_scene"

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view

    self.creds = login_common.fetchCredentials()
    if not self.creds then
        return
    end

    -- Set the default values for the game density & bonuses layout
    new_game_data.gameDensity = new_game_data.gameDensity or common_api.MEDIUM_DENSITY
    new_game_data.bonusesType = new_game_data.bonusesType or common_api.RANDOM_BONUSES

    self.background = common_ui.createBackground()
    self.title = self:createTitle()
    self.gearButton = self:createGearButton()
    self.gameOptionsModal = game_options_modal.new(self, true)
    self.createGameButton = self:createJoinGameButton()
    self.backButton = common_ui.createBackButton(80, 100, "scenes.my_challengers_scene")
    self.createGameOptions = create_game_options.new(self:getOnUpdateOptionsListener(), true, 225)
    self.tokensDisplay = tokens_display.new(self, display.contentCenterX, 825, self.creds.user, self:getUpdateUserListener())

    sceneGroup:insert(self.background)
    sceneGroup:insert(self.title)
    sceneGroup:insert(self.gearButton)
    sceneGroup:insert(self.createGameButton)
    sceneGroup:insert(self.backButton)
    sceneGroup:insert(self.gameOptionsModal:render())
    sceneGroup:insert(self.createGameOptions:render())
    sceneGroup:insert(self.tokensDisplay:render())

    local currentCost = self:getCurrentCost()
    self.tokenCostInfo = token_cost_info.new(display.contentCenterX, 1075, currentCost)
    sceneGroup:insert(self.tokenCostInfo:render())

    -- Fetch updated user model if there are no pending purchases
    local purchaseJSON = purchase_store.loadPurchaseTable()
    if #purchaseJSON.purchases <= 0 then
        print("0 purchases present, updating user model.")
        common_api.getSelf(self:onGetSelfSuccess(), self:onGetSelfFail())
    else
        -- Register purchases with Ghostwriters backend, if present.
        print("Purchases are present! Registering with ghostwriters.")
        pay_helpers.registerAllPurchases()
    end

end

function scene:createTitle()
    local title = display.newText {
        text = "Join Game",
        x = display.contentCenterX,
        y = 90,
        font = fonts.BOLD_FONT,
        fontSize = 68
    }
    title:setFillColor(0, 0, 0)

    return title
end


function scene:onGetSelfSuccess()
    return function(userModel)
        login_common.updateStoredUser(userModel)
        self.tokensDisplay:updateUser(userModel)
    end
end

function scene:onGetSelfFail()
    return function()
        print("An error occurred getting an updated user model for the current user.")
    end
end

function scene:getUpdateUserListener()
    return function()
        if not self.tokensDisplay then
            return
        end

        local updatedCreds = login_common.fetchCredentials()
        if not updatedCreds then
            return
        end

        self.creds = updatedCreds

        self.tokensDisplay:updateUser(updatedCreds.user)
    end
end

function scene:getOnUpdateOptionsListener()
    return function()
        local numBlankTiles = self.createGameOptions:getNumBlankTiles()
        local numScryTiles = self.createGameOptions:getNumScryTiles()

        new_game_data.initialBlankTiles = numBlankTiles
        new_game_data.initialScryTiles = numScryTiles

        local updatedCost = self:getCurrentCost()
        self.tokenCostInfo:updateCost(updatedCost)
    end
end

function scene:getCurrentCost()
    local blankTilesCost = new_game_data.initialBlankTiles or 0
    local scryTilesCost = new_game_data.initialScryTiles or 0
    return blankTilesCost + scryTilesCost
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).


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
        -- Called when the scene is on screen (but is about to go off screen).
        scene_helpers.onWillHideScene()
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
        self.view = nil
        self.tokensDisplay = nil
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
        width = 125,
        height = 125,
        onRelease = onRelease
    }
end

function scene:createJoinGameButton()
    local text = "Join Game"
    local button = common_ui.createButton(text, 1200, self:onReleaseJoinGameButton(), 425)
    button.x = display.contentCenterX - 60
    return button
end

function scene:onReleaseJoinGameButton()
    return function(event)
        local currentScene = composer.getSceneName("current")
        if currentScene == scene.sceneName then
            local numBlankTiles = new_game_data.initialBlankTiles or 0
            local numScryTiles = new_game_data.initialScryTiles or 0
            local gameId = new_game_data.gameId

            if not gameId then
                print("ERROR - the gameId isn't defined in accept_game_scene.")
                return
            end

            -- Accept the game via the API
            common_api.acceptGameOffer(gameId, numBlankTiles, numScryTiles, self.onAcceptGameSuccess, self.onAcceptGameFail, true)
        end
    end
end

function scene.onAcceptGameSuccess(gameModel)
    local currentScene = composer.getSceneName("current")

    print("Received gameModel...")
    print(json.encode(gameModel))
    if currentScene == scene.sceneName then
        print("Going to play_game_scene...")
        current_game.currentGame = gameModel
        login_common.updateStoredUser(gameModel.player2Model)
        composer.gotoScene( "scenes.play_game_scene", "fade" )
        new_game_data.clearAll()
    else
        print("ERROR - Attempt to start a new game from create_game_scene, but current scene is now: " .. currentScene)
    end
end

function scene.onAcceptGameFail(jsonResp)
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

