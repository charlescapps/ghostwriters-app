local composer = require("composer")
local native = require("native")
local display = require("display")
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local device_id_backup = require("login.device_id_backup")
local nav = require("common.nav")
local text_progress_class = require("classes.text_progress_class")
local OneSignal = require("plugin.OneSignal")
local transition = require("transition")
local fonts = require("globals.fonts")
local login_common = require("login.login_common")

local scene = composer.newScene()

scene.sceneName = "login.welcome_scene"

function scene:createWelcomeBackText()
    local welcomeBackText = display.newText {
        text = "Welcome back,",
        font = fonts.DEFAULT_FONT,
        fontSize = 52,
        x = display.contentCenterX,
        y = 250
    }
    welcomeBackText:setFillColor(0, 0, 0)
    return welcomeBackText
end

function scene:createUsernameText()

    local usernameText = display.newText {
        text = "(Unknown)",
        font = fonts.BOLD_FONT,
        fontSize = 52,
        x = display.contentCenterX,
        y = 350
    }
    usernameText:setFillColor(0, 0, 0)
    return usernameText

end

function scene:createTextProgress()
    return text_progress_class.new(self.view, display.contentWidth / 2, display.contentHeight / 2,
        "Signing in...", 75, 0.8)
end

function scene:getOnLoginSuccessListener()
    return function(user)
        if self.textProgress then
            self.textProgress:stop()
        end
        nav.goToSceneFrom(self.sceneName, "scenes.title_scene", "fade")
        -- Tag the player in Game Thrive (OneSignal) with the user ID.
        OneSignal.TagPlayer("ghostwriters_id", user.id)
    end
end

function scene:getOnLoginFailListener()
    return function(respJson)
        if self.textProgress then
            self.textProgress:stop()
        end
        if respJson and respJson.errorMessage then
            native.showAlert("Error logging in", respJson["errorMessage"], {"OK"})
            composer.gotoScene("login.create_user_scene", "fade")
        end
    end
end

local function createGoButton()
    return common_ui.createButton("Login", 650, function() scene:loginAndGo() end)
end

function scene:createTitleImage()
    local titleImg = display.newImageRect( "images/ghostwriters_title.png", display.contentWidth, 175)
    titleImg.x = display.contentWidth / 2
    titleImg.y = 125
    return titleImg
end

function scene:loginAndGo()
    if not self.user then
        composer.gotoScene("login.logged_out_scene", "fade")
        return
    end
    local deviceId = device_id_backup.getDeviceId()

    common_api.createNewAccountAndLogin(self.user.username, nil, deviceId,
        self:getOnLoginSuccessListener(),
        self:getOnLoginFailListener(),
        true)
end

function scene:createLoginWithUsernamePassLink()
    local function onPress()
        nav.goToSceneFrom(scene.sceneName, "login.login_with_password_scene", "fade")
    end

    return common_ui.createLink("Login with player from another device",
        display.contentCenterX, 900, 36, onPress)
end


-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view
    local background = common_ui.createBackground()
    local title = self:createTitleImage()

    self.welcomeBackText = self:createWelcomeBackText()
    self.usernameText = self:createUsernameText()
    self.goButton = createGoButton()
    self.loginWithUsernamePassLink = self:createLoginWithUsernamePassLink()

    sceneGroup:insert(background)
    sceneGroup:insert(title)
    sceneGroup:insert(self.welcomeBackText)
    sceneGroup:insert(self.usernameText)
    sceneGroup:insert(self.goButton)
    sceneGroup:insert(self.loginWithUsernamePassLink)

end

-- "scene:show()"
function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        self.user = login_common.getUser()
        if not self.user then
            composer.gotoScene("login.create_user_scene")
            return
        end
        -- Set the username text on the username display
        self.usernameText.text = self.user.username

    elseif (phase == "did") then

    end
end


-- "scene:hide()"
function scene:hide(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then

    elseif (phase == "did") then
        -- Called immediately after scene goes off screen.
        self.view = nil
        composer.removeScene(self.sceneName, false)
    end
end


-- "scene:destroy()"
function scene:destroy(event)

end


-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-- -------------------------------------------------------------------------------

return scene