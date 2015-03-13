local composer = require( "composer" )
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local native = require("native")
local json = require("json")
local text_progress_class = require("classes.text_progress_class")
local scene = composer.newScene()

scene.sceneName = "login.create_account_scene"

-- Store username / email
local enteredUsername
local enteredEmail

-- Pre-declared functions
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

-- Native display objects
local usernameInput
local emailInput
local passwordInput
local passwordConfirmInput
local textProgress

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
    local textField = native.newTextField( display.contentWidth / 2, 300, 600, 80 )
    textField.size = 14
    textField.placeholder = "e.g. Ghosty McFee"
    textField:setReturnKey("next")
    return textField
end

local function create_email_label_and_desc()
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
    local textField = native.newTextField( display.contentWidth / 2, 575, 600, 80 )
    textField.size = 14
    textField.placeholder = "e.g. bob@example.com"
    textField:setReturnKey("next")
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
    local passField = native.newTextField( display.contentWidth / 2, 725, 400, 80 )
    passField.size = 20
    passField.placeholder = "Enter your password"
    passField.isSecure = true
    passField:setReturnKey("next")
    return passField
end

createPassConfirmTextField = function()
    local passConfirmField = native.newTextField( display.contentWidth / 2, 900, 400, 80 )
    passConfirmField.size = 20
    passConfirmField.placeholder = "Re-enter your password"
    passConfirmField.isSecure = true
    passConfirmField:setReturnKey("done")
    passConfirmField:addEventListener( "userInput", function(event)
        if event.phase == "submitted" then
            submit()
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
        "Creating your account...", 40, 0.8)
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
    local doneButton = common_ui.create_button("Go!", 1050, submit)
    return doneButton
end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    local backButton = common_ui.create_back_button(100, 100)
    local usernameLabelGrp = create_username_label_and_desc()
    local emailLabelGrp = create_email_label_and_desc()
    local passwordLabels = createPasswordLabels()
    local done_button = create_done_button()

    sceneGroup:insert(background)
    sceneGroup:insert(backButton)
    sceneGroup:insert(usernameLabelGrp)
    sceneGroup:insert(emailLabelGrp)
    sceneGroup:insert(passwordLabels)
    sceneGroup:insert(done_button)
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
    textProgress, enteredUsername, enteredEmail = nil, nil, nil

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