local composer = require("composer")
local native = require("native")
local widget = require("widget")
local display = require("display")
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local device_id_backup = require("login.device_id_backup")
local nav = require("common.nav")
local text_progress_class = require("classes.text_progress_class")
local transition = require("transition")
local custom_text_field = require("classes.custom_text_field")
local fonts = require("globals.fonts")

local scene = composer.newScene()

scene.sceneName = "login.create_user_scene"

-- Constants
local MIN_USERNAME_LEN = 4
local MAX_USERNAME_LEN = 16

function scene:createAccountAndGo()
    if self.createInProgress then
        print("Request already in progress to create new user.")
        return
    end

    local username = self.storedUsername or self.usernameTextField and self.usernameTextField:getText()
    local deviceId = device_id_backup.getDeviceId()
    if not username or username:len() <= 0 then
        common_ui.createInfoModal("Oops...", "Please enter a username")
    elseif username:len() < MIN_USERNAME_LEN then
        common_ui.createInfoModal("Oops...", "Usernames must be at least " .. MIN_USERNAME_LEN .. " letters.")
    elseif username:len() > MAX_USERNAME_LEN then
        common_ui.createInfoModal("Oops...", "Usernames can't be more than " .. MAX_USERNAME_LEN .. " letters.")
    else
        local currentScene = composer.getSceneName("current")
        if currentScene == self.sceneName then
            if self.goButton then
                self.goButton:setEnabled(false)
            end
            self:createTextProgress()
            self.createInProgress = true
            common_api.createNewAccountAndLogin(username, nil, deviceId,
                self:getOnCreateAccountSuccessListener(), self:getOnCreateAccountFailListener())
            native.setKeyboardFocus(nil)
        end
    end
end

function scene:createUsernameInput()
    local function inputListener(event)
        if event.phase == "began" then

        elseif event.phase == "editing" then
            if event.text and event.text:len() > MAX_USERNAME_LEN then
                self:setUsernameText(event.text:sub(1, MAX_USERNAME_LEN))
            end
            if event.text then
               local textNoSpaces = string.gsub(event.text, "%s+", "")
                self:setUsernameText(textNoSpaces)
            end
        elseif event.phase == "submitted" then
            print("Submitted username input...")
            self:createAccountAndGo()
            native.setKeyboardFocus(nil)
        elseif event.phase == "ended" then
        end
        return true
    end

    local usernameTextField = custom_text_field.newCustomTextField
        {
            x = display.contentWidth / 2,
            y = 400,
            width = 450,
            height = 90,
            placeholder = "e.g. Ghosty McFee",
            fontSize = nil,  -- Will resize automatically.
            font = fonts.DEFAULT_FONT,
            backgroundColor = { 1, 1, 1, 0.6 },
            align = "center",
            listener = inputListener
        }

    usernameTextField.textField:setReturnKey("done")
    return usernameTextField
end

-- Store the username in the text field AND a member field,
-- because the text field doesn't update immediately on Android due to how Corona works with multi-threading
function scene:setUsernameText(newUsername)
    self.usernameTextField:setText(newUsername)
    self.storedUsername = newUsername
end

function scene:createGetNextUsernameButton()
    return widget.newButton {
        x = 680,
        y = 400,
        onEvent = function(event)
            if event.phase == "began" then
                display.getCurrentStage():setFocus(event.target)
            elseif event.phase == "ended" then
                display.getCurrentStage():setFocus(nil)
                self:getNextUsername()
            elseif event.phase == "cancelled" then
                display.getCurrentStage():setFocus(nil)
            end
            return true
        end,
        width = 130,
        height = 130,
        defaultFile = "images/reset_button_default.png",
        overFile = "images/reset_button_over.png"
    }
end

local function createUsernameInputLabel()

    local usernameLabel = display.newText {
        x = display.contentWidth / 2,
        y = 300,
        font = native.systemFont,
        fontSize = 54,
        text = "Choose your name"
    }

    usernameLabel:setFillColor(0, 0, 0)

    return usernameLabel
end

function scene:createTextProgress()
    print("Creating text progress...")
    self:destroyTextProgress()
    self.textProgress = text_progress_class.new(self.view, display.contentWidth / 2, display.contentHeight / 2,
        "Creating user...", 75, 0.8)
    self.textProgress:start()
end

function scene:getOnCreateAccountSuccessListener()
    return function(user)
        self:destroyTextProgress()
        nav.goToSceneFrom(self.sceneName, "scenes.title_scene", "fade")
        self.createInProgress = nil
    end
end

function scene:destroyTextProgress()
    if self.textProgress then
        self.textProgress:stop()
        self.textProgress = nil
    end
end

function scene:getOnCreateAccountFailListener()
    return function(jsonResp)
        print("Login failed...destroying text progress widget and re-enabling the Go Button.")
        self:destroyTextProgress()

        self.goButton:setEnabled(true)

        if jsonResp and jsonResp["errorMessage"] then
            common_ui.createInfoModal("Error creating user", jsonResp["errorMessage"], nil, 48)
        end

        self.createInProgress = nil
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
    local button = common_ui.createButton("Go!", 550, function()
        scene:createAccountAndGo()
        return true
    end)
    button.x = display.contentCenterX
    return button
end

function scene:getNextUsername()
    local deviceId = device_id_backup.getDeviceId()
    print("Found device ID: " .. deviceId)

    common_api.getNextUsername(deviceId, self:getOnGetNextUsernameSuccessListener(), self:getOnGetNextUsernameFailListener(), true)
end

function scene:createTitleImage()
    local titleImg = display.newImageRect( "images/ghostwriters_title.png", display.contentWidth, 175)
    titleImg.x = display.contentWidth / 2
    titleImg.y = 125
    return titleImg
end

function scene:createLoginWithUsernamePassLink()
    local function onPress()
        nav.goToSceneFrom(scene.sceneName, "login.login_with_password_scene", "fade")
        return true
    end

    return common_ui.createLink("Login as existing player",
        display.contentCenterX, 900, 52, onPress)
end


-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view
    local background = common_ui.createBackground()
    local title = self:createTitleImage()
    self.usernameInputLabel = createUsernameInputLabel()
    self.getNextUsernameButton = self:createGetNextUsernameButton()
    self.goButton = createGoButton()
    self.loginWithUserPassLink = self:createLoginWithUsernamePassLink()

    sceneGroup:insert(background)
    sceneGroup:insert(title)
    sceneGroup:insert(self.usernameInputLabel)
    sceneGroup:insert(self.getNextUsernameButton)
    sceneGroup:insert(self.goButton)
    sceneGroup:insert(self.loginWithUserPassLink)

end

-- "scene:show()"
function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Called when the scene is still off screen (but is about to come on screen).
        self.usernameTextField = self:createUsernameInput()
        sceneGroup:insert(self.usernameTextField)
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

    if phase == "will" then
        self:destroyTextProgress()
        if self.usernameTextField then
           self.usernameTextField:removeSelf()
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