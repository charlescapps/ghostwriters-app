local composer = require("composer")
local native = require("native")
local display = require("display")
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
local usernameTextField
local passwordTextField
local textProgress

local function create_button_new_account()
    return common_ui.create_button("Create a new user", 300,
        function()
            nav.goToSceneFrom(scene.sceneName, "login.create_account_scene", "fade")
        end )
end


local function createNativeInputs()

    usernameTextField = native.newTextField(display.contentWidth / 2, 750, 3 * display.contentWidth / 4, 80)
    passwordTextField = native.newTextField(display.contentWidth / 2, 950, 3 * display.contentWidth / 4, 80)

    usernameTextField.placeholder = "Username or email"
    passwordTextField.placeholder = "Password"

    usernameTextField.size, passwordTextField.size = 12, 12
    usernameTextField.align, passwordTextField.align = "center", "center"
    passwordTextField.isSecure = true
end

local function removeNativeInputs()
    if usernameTextField then
        usernameTextField:removeSelf()
        usernameTextField = nil
    end
    if passwordTextField then
        passwordTextField:removeSelf()
        passwordTextField = nil
    end
end

local function create_sign_in_texts()
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

local function createTextProgress()
    return text_progress_class.new(scene.view, display.contentWidth / 2, display.contentHeight / 2,
        "Signing in...", 80, 0.8)
end

local function onLoginSuccess()
    textProgress:stop()
    nav.goToSceneFrom(scene.sceneName, "scenes.title_scene", "fade")
end

local function onLoginFail()
    print("Login failed...")
    textProgress:stop(function()
        createNativeInputs()
    end)
end

local function create_button_sign_in()
    return common_ui.create_button("Sign in", 1150, function(event)
        local username = usernameTextField.text
        local password = passwordTextField.text
        if not username or not password or username:len() <= 0 or password:len() <= 0 then
            native.showAlert("Oops...", "Please enter a username and password", {"OK"})
        elseif username:len() < MIN_USERNAME_LEN then
            native.showAlert("Oops...", "Usernames must be at least " .. MIN_USERNAME_LEN .. " characters long.", {"OK"})
        elseif password:len() < MIN_PASSWORD_LEN then
            native.showAlert("Oops...", "Passwords must be at least " .. MIN_PASSWORD_LEN .. " characters long.", {"OK"})
        else
            local currentScene = composer.getSceneName("current")
            if currentScene == scene.sceneName then
                removeNativeInputs()
                textProgress = createTextProgress()
                textProgress:start()
                common_api.login(username, password, onLoginSuccess, onLoginFail)
            end
        end
    end)
end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    local title = common_ui.create_title("Words with Rivals", nil, { 0, 0, 0})
    local button_new_account = create_button_new_account()
    local signInTexts = create_sign_in_texts()
    local signInButton = create_button_sign_in()

    sceneGroup:insert(background)
    sceneGroup:insert(title)    
    sceneGroup:insert(button_new_account)
    sceneGroup:insert(signInTexts)
    sceneGroup:insert(signInButton)

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
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
        removeNativeInputs()
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