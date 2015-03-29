local composer = require( "composer" )
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local native = require("native")
local display = require("display")
local widget = require("widget")
local json = require("json")
local text_progress_class = require("classes.text_progress_class")
local scene = composer.newScene()

scene.sceneName = "login.create_account_scene"

-- Store username / email
local enteredUsername
local enteredEmail

-- Pre-declared functions
local createScrollView
local createUsernameTextField
local createEmailTextField
local createPassTextField
local createPassConfirmTextField
local createNativeFields
local removeNativeFields
local createAccountSuccess
local createAccountFail
local submit
local createTextProgress

-- Display objects
local scrollView
local textProgress

-- Native
local usernameInput
local emailInput
local passwordInput
local passwordConfirmInput

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

createNativeFields = function()
    usernameInput = createUsernameTextField()
    if enteredUsername then
        usernameInput.text = enteredUsername
    end
    emailInput = createEmailTextField()
    if enteredEmail then
        emailInput.text = enteredEmail
    end
    passwordInput = createPassTextField()
    passwordConfirmInput = createPassConfirmTextField()

    scrollView:insert(usernameInput)
    scrollView:insert(emailInput)
    scrollView:insert(passwordInput)
    scrollView:insert(passwordConfirmInput)
end

removeNativeFields = function()
    if usernameInput then
        usernameInput:removeSelf()
        usernameInput = nil
    end
    if emailInput then
        emailInput:removeSelf()
        emailInput = nil
    end
    if passwordInput then
        passwordInput:removeSelf()
        passwordInput = nil
    end
    if passwordConfirmInput then
        passwordConfirmInput:removeSelf()
        passwordConfirmInput = nil
    end
end

local function create_username_label_and_desc()
    local group = display.newGroup()
    local usernameLabel = display.newText( "Choose your username", display.contentWidth / 2, 175, native.systemFontBold, 40 )
    usernameLabel:setFillColor( 0, 0, 0 )

    local usernameDesc = display.newText( "(This is what other players will see.)", display.contentWidth / 2, 225, native.systemFont, 30 )
    usernameDesc:setFillColor( 0, 0, 0 )

    group:insert(usernameLabel)
    group:insert(usernameDesc)
    return group
end

createUsernameTextField = function()
    local textField = native.newTextField( display.contentWidth / 2, 300, 2 * display.contentWidth / 3, 80 )
    textField.size = 16
    textField.placeholder = "e.g. Ghosty McFee"
    textField:setReturnKey("next")
    textField.align = "center"
    return textField
end

local function createEmailLabelGroup()
    local group = display.newGroup()

    local emailLabel = display.newText( "Enter a valid email", display.contentWidth / 2, 400, native.systemFontBold, 40 )
    emailLabel:setFillColor( 0, 0, 0 )

    local emailDesc = display.newText {
        text = "(Optional: this is required to recover your password and verify your account.)",
        x = display.contentWidth / 2,
        y = 475,
        font = native.systemFont,
        fontSize = 30,
        width = 7 * display.contentWidth / 8,
        align = "center"}
    emailDesc:setFillColor( 0, 0, 0 )

    group:insert(emailLabel)
    group:insert(emailDesc)

    return group
end

createEmailTextField = function()
    local textField = native.newTextField( display.contentWidth / 2, 575, 2 * display.contentWidth / 3, 80 )
    textField.size = 16
    textField.placeholder = "e.g. bob@example.com"
    textField:setReturnKey("next")
    textField.align = "center"
    textField.inputType = "email"
    textField:addEventListener("userInput", function(event)
        if event.phase == "began" then
            scrollView:scrollToPosition {
                y = -100,
                time = 500
            }
        elseif event.phase == "ended" then
            scrollView:scrollToPosition {
                y = 0,
                time = 500
            }
        end
    end)
    return textField
end

submit = function()
    if composer.getSceneName("current") ~= scene.sceneName then
        return
    end

    local result = scene:sanityCheckDetails()
    if result["error"] ~= nil then
        native.showAlert( "Oops...", result["error"], { "Try again" } )
    else
        enteredUsername = usernameInput.text
        enteredEmail = emailInput.text

        removeNativeFields()
        textProgress = createTextProgress()
        textProgress:start()
        common_api.createNewAccountAndLogin(result["username"], result["email"], result["password"],
            createAccountSuccess, createAccountFail)
    end
end

createPassTextField = function()
    local passField = native.newTextField( display.contentWidth / 2, 725, 2 * display.contentWidth / 3, 80 )
    passField.size = 16
    passField.placeholder = "Enter your password"
    passField.isSecure = true
    passField:setReturnKey("next")
    passField:addEventListener("userInput", function(event)
        if event.phase == "began" then
            scrollView:scrollToPosition {
                y = -200,
                time = 500
            }
        elseif event.phase == "ended" then
            scrollView:scrollToPosition {
                y = 0,
                time = 500
            }
        end
    end)
    return passField
end

createPassConfirmTextField = function()
    local passConfirmField = native.newTextField( display.contentWidth / 2, 900, 2 * display.contentWidth / 3, 80 )
    passConfirmField.size = 16
    passConfirmField.placeholder = "Re-enter your password"
    passConfirmField.isSecure = true
    passConfirmField:setReturnKey("done")
    passConfirmField:addEventListener( "userInput", function(event)
        if event.phase == "began" then
            scrollView:scrollToPosition {
                y = -300,
                time = 500
            }
        elseif event.phase == "submitted" then
            submit()
        elseif event.phase == "ended" then
            scrollView:scrollToPosition {
                y = 0,
                time = 500
            }
        end
    end )
    return passConfirmField
end

local function createPasswordLabels()
    local group = display.newGroup( )
    local passLabel = display.newText( "Enter a password", display.contentWidth / 2, 650, native.systemBoldFont, 40 )
    passLabel:setFillColor( 0, 0, 0 )
    
    local passConfirmLabel = display.newText( "Re-enter your password", display.contentWidth / 2, 825, native.systemBoldFont, 40 )
    passConfirmLabel:setFillColor( 0, 0, 0 )

    group:insert(passLabel)
    group:insert(passConfirmLabel)

    return group
end

createTextProgress = function()
    return text_progress_class.new(scene.view, display.contentWidth / 2, display.contentHeight / 2,
        "Creating your account...", 50, 0.8)
end

function scene:sanityCheckDetails()
    local group = self.view
    local username = usernameInput.text
    print ("Username entered = " .. username)

    local email = emailInput.text
    print ("Email entered = " .. email) 

    local pass = passwordInput.text
    local passConfirm = passwordConfirmInput.text
    print ("Password entered = " .. pass)
    print ("Password confirm = " .. passConfirm)

    if not username then
        return { error = "Please enter a username" }
    end 

    if username:len() < 4 then
        return { error = "Username must be at least 4 characters." }
    end

    if not email then
        return { error = "Please enter an email" }
    end

    if email:len() < 5 or email:find("@") == nil then
        return { error = "Please enter a valid email" }
    end

    if not pass then
        return { error = "Please enter your password" }
    end

    if pass:len() < 4 then
        return { error = "Passwords must be at least 4 characters" }
    end

    if not passConfirm then
        return { error = "Please re-enter your password" }
    end

    if pass ~= passConfirm then
        return { error = "Passwords entered do not match" }
    end

    return {
        username = username,
        password = pass,
        email = email
        }

end

createAccountSuccess = function(user)
    if textProgress then
        textProgress:stop()
    end

    if composer.getSceneName("current") ~= scene.sceneName then
        return
    end

    print("Creating account was a success: " .. json.encode( user ))
    local currentSceneName = composer.getSceneName( "current" )
    composer.removeScene( currentSceneName, false )
    composer.gotoScene( "scenes.title_scene", "fade" )
end

createAccountFail = function()
    textProgress:stop(function()
        createNativeFields()
    end)
end

local function create_done_button()
    local doneButton = common_ui.createButton("Go!", 1050, submit)
    return doneButton
end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.createBackground()
    local backButton = common_ui.createBackButton(100, 100)
    local usernameLabelGrp = create_username_label_and_desc()
    local emailLabelGrp = createEmailLabelGroup()
    local passwordLabels = createPasswordLabels()
    local done_button = create_done_button()
    scrollView = createScrollView()

    sceneGroup:insert(background)
    sceneGroup:insert(scrollView)
    scrollView:insert(backButton)
    scrollView:insert(usernameLabelGrp)
    scrollView:insert(emailLabelGrp)
    scrollView:insert(passwordLabels)
    scrollView:insert(done_button)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        createNativeFields()
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
        removeNativeFields()
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
    removeNativeFields()
    if textProgress then
        textProgress:stop()
    end
    scrollView, textProgress, enteredUsername, enteredEmail = nil, nil, nil

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