local composer = require("composer")
local native = require("native")
local widget = require("widget")
local display = require("display")
local word_spinner_class = require("classes.word_spinner_class")
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local nav = require("common.nav")
local system = require("system")
local text_progress_class = require("classes.text_progress_class")

local scene = composer.newScene()

scene.sceneName = "login.logged_out_scene"

-- Constants
local MIN_USERNAME_LEN = 4
local MAX_USERNAME_LEN = 16

-- Display objects
local usernameTextField
local deviceUsernameText
local passwordTextField
local textProgress
local wordSpinner

-- Pre-declated functions
local createUsernameInput
local createDeviceUsernameText
local createGetNextUsernameButton
local removeNativeInputs
local createAccountAndGo
local getNextUsername
local createTextProgress

-- Callbacks
local onCreateAccountSuccess
local onCreateAccountFail

local onGetNextUsernameSuccess
local onGetNextUsernameFail

-- Stored values
local storedUsername

local function createSecondaryDeviceLink()
    return common_ui.createLink("Sign in as user from another device?", nil, 900, nil, function()
        nav.goToSceneFrom(scene.sceneName, "login.login_existing_user_scene")
    end)
end

createAccountAndGo = function()
    local username = deviceUsernameText and deviceUsernameText.text or usernameTextField.text
    local deviceId = system.getInfo("deviceID")
    if not username or username:len() <= 0 then
        native.showAlert("Oops...", "Please enter a username", {"OK"})
    elseif username:len() < MIN_USERNAME_LEN then
        native.showAlert("Oops...", "Usernames must be at least " .. MIN_USERNAME_LEN .. " characters long.", {"OK"})
    elseif username:len() > MAX_USERNAME_LEN then
        native.showAlert("Oops...", "Usernames can't be longer than " .. MAX_USERNAME_LEN .. " characters long.", {"OK"})
    else
        storedUsername = username
        local currentScene = composer.getSceneName("current")
        if currentScene == scene.sceneName then
            removeNativeInputs()
            textProgress = createTextProgress()
            textProgress:start()
            common_api.createNewAccountAndLogin(username, nil, deviceId,
                onCreateAccountSuccess, onCreateAccountFail)
        end
    end
end

createUsernameInput = function()

    usernameTextField = native.newTextField(display.contentWidth / 2, 400, 475, 80)

    usernameTextField.isFontSizeScaled = true
    usernameTextField.size = 16
    usernameTextField.placeholder = "e.g. Ghosty McFee"
    usernameTextField:setReturnKey("done")
    if storedUsername then
        usernameTextField.text = storedUsername
    end

    usernameTextField.align = "center"

    usernameTextField:addEventListener("userInput", function(event)
        if event.phase == "editing" then
            if event.text and event.text:len() > MAX_USERNAME_LEN then
               usernameTextField.text = event.text:sub(1, MAX_USERNAME_LEN)
            end
        elseif event.phase == "submitted" then
            createAccountAndGo()
        end
    end)
end

createDeviceUsernameText = function(deviceUsername)
    deviceUsernameText = display.newText {
        x = display.contentWidth / 2,
        y = 400,
        text = deviceUsername,
        align = "center",
        font = native.systemFontBold,
        fontSize = 40
    }
    deviceUsernameText:setFillColor(0, 0, 0)
    return deviceUsernameText
end

createGetNextUsernameButton = function()
    return widget.newButton {
        x = 675,
        y = 400,
        onRelease = getNextUsername,
        width = 80,
        height = 80,
        defaultFile = "images/refresh_username_icon.png",
        overFile = "images/refresh_username_icon_dark.png"
    }
end

removeNativeInputs = function()
    if usernameTextField then
        usernameTextField:removeSelf()
        usernameTextField = nil
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

createTextProgress = function()
    return text_progress_class.new(scene.view, display.contentWidth / 2, display.contentHeight / 2,
        "Signing in...", 75, 0.8)
end

onCreateAccountSuccess = function()
    textProgress:stop()
    nav.goToSceneFrom(scene.sceneName, "scenes.title_scene", "fade")
end

onCreateAccountFail = function()
    print("Login failed...")
    textProgress:stop(function()
        createUsernameInput()
        native.showAlert("Network Error", "Ghostwriters requires an Internet Connection to play.", { "Try again" })
    end)
end

onGetNextUsernameSuccess = function(nextUsername)
    wordSpinner:stop()
    local username = nextUsername.nextUsername
    local required = nextUsername.required
    if usernameTextField then
        usernameTextField.text = username
    end
    if username and required then
       deviceUsernameText = createDeviceUsernameText(username)
       scene.view:insert(deviceUsernameText)
       removeNativeInputs()
    end
end

onGetNextUsernameFail = function()
    wordSpinner:stop()
    native.showAlert("Network Error", "Ghostwriters requires an Internet Connection to play.", { "Try again" })
end

local function createGoButton()
    return common_ui.create_button("Go!", 550, createAccountAndGo)
end

getNextUsername = function()
    if deviceUsernameText and deviceUsernameText.text then
        return
    end
    wordSpinner = word_spinner_class.new()
    wordSpinner:start()

    local deviceId = system.getInfo("deviceID")
    print("Found device ID: " .. deviceId)

    common_api.getNextUsername(deviceId, onGetNextUsernameSuccess, onGetNextUsernameFail)
end


-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    local title = common_ui.create_title("Ghost Writers", nil, { 0, 0, 0 }, 55)
    local usernameInputLabel = createUsernameInputLabel()
    local getNextUsernameButton = createGetNextUsernameButton()
    local createAccountAndGoButton = createGoButton()
    local secondDeviceButton = createSecondaryDeviceLink()

    sceneGroup:insert(background)
    sceneGroup:insert(title)
    sceneGroup:insert(usernameInputLabel)
    sceneGroup:insert(getNextUsernameButton)
    sceneGroup:insert(createAccountAndGoButton)
    sceneGroup:insert(secondDeviceButton)

    getNextUsername()

end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        createUsernameInput()
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
        removeNativeInputs()
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view
    removeNativeInputs()
    storedUsername = nil
    if textProgress then
        textProgress:stop()
        textProgress = nil
    end
    if wordSpinner then
        wordSpinner:stop()
        wordSpinner = nil
    end
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