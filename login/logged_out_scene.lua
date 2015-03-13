local composer = require("composer")
local native = require("native")
local display = require("display")
local widget = require("widget")
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local nav = require("common.nav")
local text_progress_class = require("classes.text_progress_class")

local scene = composer.newScene()

scene.sceneName = "login.logged_out_scene"

-- Constants
local MIN_PASSWORD_LEN = 4
local MIN_USERNAME_LEN = 4

-- Display objects
local scrollView
local usernameTextField
local passwordTextField
local textProgress

-- Pre-declated functions
local createScrollView
local createNativeInputs
local removeNativeInputs
local signIn
local createTextProgress
local onLoginSuccess
local onLoginFail

-- Stored values
local storedUsername
local storedPassword

local function createNewAccountButton()
    return common_ui.create_button("Create a new user", 300,
        function()
            nav.goToSceneFrom(scene.sceneName, "login.create_account_scene", "fade")
        end )
end

signIn = function()
    local username = usernameTextField.text
    local password = passwordTextField.text
    if not username or not password or username:len() <= 0 or password:len() <= 0 then
        native.showAlert("Oops...", "Please enter a username and password", {"OK"})
    elseif username:len() < MIN_USERNAME_LEN then
        native.showAlert("Oops...", "Usernames must be at least " .. MIN_USERNAME_LEN .. " characters long.", {"OK"})
    elseif password:len() < MIN_PASSWORD_LEN then
        native.showAlert("Oops...", "Passwords must be at least " .. MIN_PASSWORD_LEN .. " characters long.", {"OK"})
    else
        storedUsername = username
        storedPassword = password
        local currentScene = composer.getSceneName("current")
        if currentScene == scene.sceneName then
            removeNativeInputs()
            textProgress = createTextProgress()
            textProgress:start()
            common_api.login(username, password, onLoginSuccess, onLoginFail)
        end
    end
end

createScrollView = function()
    return widget.newScrollView {
        x = display.contentWidth / 2,
        y = display.contentHeight / 2,
        width = display.contentWidth,
        height = display.contentHeight,
        scrollWidth = display.contentWidth,
        scrollHeight = 3 * display.contentHeight / 2,
        horizontalScrollDisabled = true,
        hideBackground = true,
        hideScrollBar = true
    }
end

createNativeInputs = function()

    usernameTextField = native.newTextField(display.contentWidth / 2, 750, 3 * display.contentWidth / 4, 80)
    passwordTextField = native.newTextField(display.contentWidth / 2, 950, 3 * display.contentWidth / 4, 80)

    usernameTextField.isFontSizeScaled = true
    usernameTextField.placeholder = "Username or email"
    usernameTextField:setReturnKey("next")
    if storedUsername then
        usernameTextField.text = storedUsername
    end

    passwordTextField.isFontSizeScaled = true
    passwordTextField.placeholder = "Password"
    passwordTextField:setReturnKey("done")
    if storedPassword then
        passwordTextField.text = storedPassword
    end

    usernameTextField.size, passwordTextField.size = 16, 16
    usernameTextField.align, passwordTextField.align = "center", "center"
    passwordTextField.isSecure = true

    scrollView:insert(usernameTextField)
    scrollView:insert(passwordTextField)

    usernameTextField:addEventListener("userInput", function(event)
        if event.phase == "began" then
            scrollView:scrollToPosition{
                y = - 100,
                time = 500
            }
        elseif event.phase == "ended" then
            scrollView:scrollToPosition{
                y = 0,
                time = 500
            }
        end
    end)

    passwordTextField:addEventListener("userInput", function(event)
        if event.phase == "began" then
            scrollView:scrollToPosition{
                y = - 300,
                time = 500
            }
        elseif event.phase == "submitted" then
            signIn()
        elseif event.phase == "ended" then
            scrollView:scrollToPosition{
                y = 0,
                time = 500
            }
        end
    end)
end

removeNativeInputs = function()
    if usernameTextField then
        usernameTextField:removeSelf()
        usernameTextField = nil
    end
    if passwordTextField then
        passwordTextField:removeSelf()
        passwordTextField = nil
    end
end

local function createSignInTexts()
    local group = display.newGroup()

    local orText = display.newText {
        x = display.contentWidth / 2,
        y = 450,
        font = native.systemFontBold,
        fontSize = 75,
        text = "~ or ~"
    }

    local signInText = display.newText {
        x = display.contentWidth / 2,
        y = 550,
        font = native.systemFont,
        fontSize = 60,
        text = "Sign in"
    }

    local usernameLabel = display.newText {
        x = display.contentWidth / 2,
        y = 675,
        font = native.systemFont,
        fontSize = 50,
        text = "Enter Username"
    }

    local passwordLabel = display.newText {
        x = display.contentWidth / 2,
        y = 875,
        font = native.systemFont,
        fontSize = 50,
        text = "Enter password"
    }

    orText:setFillColor(0, 0, 0)
    signInText:setFillColor(0, 0, 0)
    usernameLabel:setFillColor(0, 0, 0)
    passwordLabel:setFillColor(0, 0, 0)

    group:insert(orText)
    group:insert(signInText)
    group:insert(usernameLabel)
    group:insert(passwordLabel)

    return group
end

createTextProgress = function()
    return text_progress_class.new(scene.view, display.contentWidth / 2, display.contentHeight / 2,
        "Signing in...", 80, 0.8)
end

onLoginSuccess = function()
    textProgress:stop()
    nav.goToSceneFrom(scene.sceneName, "scenes.title_scene", "fade")
end

onLoginFail = function()
    print("Login failed...")
    textProgress:stop(function()
        createNativeInputs()
    end)
end

local function createSignInButton()
    return common_ui.create_button("Sign in", 1150, signIn)
end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    local title = common_ui.create_title("Words with Rivals", nil, { 0, 0, 0 })
    local newAccountButton = createNewAccountButton()
    local signInTexts = createSignInTexts()
    local signInButton = createSignInButton()
    scrollView = createScrollView()

    sceneGroup:insert(background)
    sceneGroup:insert(scrollView)
    scrollView:insert(title)
    scrollView:insert(newAccountButton)
    scrollView:insert(signInTexts)
    scrollView:insert(signInButton)

end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        createNativeInputs()
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
    storedUsername, storedPassword = nil, nil
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