local composer = require("composer")
local native = require("native")
local widget = require("widget")
local display = require("display")
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local nav = require("common.nav")
local system = require("system")
local text_progress_class = require("classes.text_progress_class")
local GameThrive = require("plugin.GameThrivePushNotifications")
local one_signal_util = require("push.one_signal_util")
local transition = require("transition")

local scene = composer.newScene()

scene.sceneName = "login.logged_out_scene"

-- Constants
local MIN_USERNAME_LEN = 4
local MAX_USERNAME_LEN = 16

function scene:createSecondaryDeviceLink()
    return common_ui.createLink("Sign in as user from another device?", nil, 900, nil, function()
        nav.goToSceneFrom(self.sceneName, "login.login_existing_user_scene")
    end)
end

function scene:createAccountAndGo()
    local username = self.storedUsername or self.usernameTextField.text
    local deviceId = system.getInfo("deviceID")
    if not username or username:len() <= 0 then
        native.showAlert("Oops...", "Please enter a username", { "OK" })
    elseif username:len() < MIN_USERNAME_LEN then
        native.showAlert("Oops...", "Usernames must be at least " .. MIN_USERNAME_LEN .. " characters long.", { "OK" })
    elseif username:len() > MAX_USERNAME_LEN then
        native.showAlert("Oops...", "Usernames can't be longer than " .. MAX_USERNAME_LEN .. " characters long.", { "OK" })
    else
        local currentScene = composer.getSceneName("current")
        if currentScene == self.sceneName then
            self.textProgress = self:createTextProgress()
            self.textProgress:start()
            if self.goButton then
                self.goButton:setEnabled(false)
            end
            common_api.createNewAccountAndLogin(username, nil, deviceId,
                self:getOnCreateAccountSuccessListener(), self:getOnCreateAccountFailListener())
        end
    end
end

function scene:createUsernameInput()

    self.usernameTextField = native.newTextField(display.contentWidth / 2, 400, 475, 80)

    self.usernameTextField.isFontSizeScaled = true
    self.usernameTextField.size = 16
    self.usernameTextField.placeholder = "e.g. Ghosty McFee"
    self.usernameTextField:setReturnKey("done")

    self.usernameTextField.align = "center"

    self.usernameTextField:addEventListener("userInput", function(event)
        if event.phase == "editing" then
            if event.text and event.text:len() > MAX_USERNAME_LEN then
                self:setUsernameText(event.text:sub(1, MAX_USERNAME_LEN))
            else
                self:setUsernameText(event.text)
            end
        elseif event.phase == "submitted" then
            self:createAccountAndGo()
        end
    end)
end

-- Store the username in the text field AND a member field,
-- because the text field doesn't update immediately on Android due to how Corona works with multi-threading
function scene:setUsernameText(newUsername)
    self.usernameTextField.text = newUsername
    self.storedUsername = newUsername
end

function scene:createGetNextUsernameButton()
    return widget.newButton {
        x = 675,
        y = 400,
        onRelease = function() self:getNextUsername() end,
        width = 80,
        height = 80,
        defaultFile = "images/refresh_username_icon.png",
        overFile = "images/refresh_username_icon_dark.png"
    }
end

function scene:removeNativeInputs()
    if self.usernameTextField then
        local function removeMe()
            self.usernameTextField:removeSelf()
            self.usernameTextField = nil
        end
        transition.fadeOut(self.usernameTextField, { time = 1000, onComplete = removeMe, onCancel = removeMe})
    end
end

local function createUsernameInputLabel()

    local usernameLabel = display.newText {
        x = display.contentWidth / 2,
        y = 300,
        font = native.systemFont,
        fontSize = 50,
        text = "Choose your name!"
    }

    usernameLabel:setFillColor(0, 0, 0)

    return usernameLabel
end

function scene:createTextProgress()
    return text_progress_class.new(self.view, display.contentWidth / 2, display.contentHeight / 2,
        "Signing in...", 75, 0.8)
end

function scene:getOnCreateAccountSuccessListener()
    return function(user)
        if self.textProgress then
            self.textProgress:stop()
        end
        if self.pushData then
            one_signal_util.actOnPushData(self.pushData, self.sceneName)
            return
        end
        nav.goToSceneFrom(self.sceneName, "scenes.title_scene", "fade")
        -- Tag the player in Game Thrive (OneSignal) with the user ID.
        GameThrive.TagPlayer("ghostwriters_id", user.id)
    end
end

function scene:getOnCreateAccountFailListener()
    return function()
        print("Login failed...re-enabling the Go Button.")
        self.goButton:setEnabled(true)

        if self.textProgress then
            self.textProgress:stop()
        end
        native.showAlert("Network Error", "Ghostwriters requires an Internet Connection to play.", { "Try again" })
    end
end

function scene:getOnGetNextUsernameSuccessListener()
    return function(nextUsername)
        local username = nextUsername.nextUsername
        local required = nextUsername.required
        if self.usernameTextField then
            self:setUsernameText(username)
        end
        if username and required then
           self:createAccountAndGo()
        end
    end
end

function scene:getOnGetNextUsernameFailListener()
    return function()
        native.showAlert("Network Error", "Ghostwriters requires an Internet Connection to play.", { "Try again" })
    end
end

local function createGoButton()
    return common_ui.createButton("Go!", 550, function() scene:createAccountAndGo() end)
end

function scene:getNextUsername()
    local deviceId = system.getInfo("deviceID")
    print("Found device ID: " .. deviceId)

    common_api.getNextUsername(deviceId, self:getOnGetNextUsernameSuccessListener(), self:getOnGetNextUsernameFailListener(), true)
end


-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view
    local background = common_ui.createBackground()
    local title = common_ui.createTitle("Ghostwriters", nil, { 0, 0, 0 }, 60)
    self.usernameInputLabel = createUsernameInputLabel()
    self.getNextUsernameButton = self:createGetNextUsernameButton()
    self.goButton = createGoButton()
    local secondDeviceButton = self:createSecondaryDeviceLink()

    sceneGroup:insert(background)
    sceneGroup:insert(title)
    sceneGroup:insert(self.usernameInputLabel)
    sceneGroup:insert(self.getNextUsernameButton)
    sceneGroup:insert(self.goButton)
    sceneGroup:insert(secondDeviceButton)

end

-- "scene:show()"
function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Called when the scene is still off screen (but is about to come on screen).
        self:createUsernameInput()
        if self.nextUsername and self.usernameTextField then
            self:setUsernameText(self.nextUsername)
            self.nextUsername = nil
        else
            self:getNextUsername()
        end
    elseif (phase == "did") then
    end
end


-- "scene:hide()"
function scene:hide(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        self:removeNativeInputs()
        if self.textProgress then
            self.textProgress:stop()
            self.textProgress = nil
        end
        transition.cancel()
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