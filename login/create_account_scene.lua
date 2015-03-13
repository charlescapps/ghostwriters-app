local composer = require( "composer" )
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local native = require("native")
local json = require("json")
local scene = composer.newScene()

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

local function create_username_text_field()
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

local function create_email_text_field()
    local textField = native.newTextField( display.contentWidth / 2, 575, 600, 80 )
    textField.size = 14
    textField.placeholder = "e.g. bob@example.com"
    textField:setReturnKey("next")
    return textField
end

local function create_password_fields()
    local group = display.newGroup( )
    local passLabel = display.newText( "Enter a password", display.contentWidth / 2, 650, native.systemBoldFont, 40 )
    passLabel:setFillColor( 0, 0, 0 )
    
    local passField = native.newTextField( display.contentWidth / 2, 725, 400, 80 )
    passField.size = 20
    passField.placeholder = "Enter your password"
    passField.isSecure = true
    passField:setReturnKey("next")


    local passConfirmLabel = display.newText( "Re-enter your password", display.contentWidth / 2, 825, native.systemBoldFont, 40 )
    passConfirmLabel:setFillColor( 0, 0, 0 )
    
    local passConfirmField = native.newTextField( display.contentWidth / 2, 900, 400, 80 )
    passConfirmField.size = 20
    passConfirmField.placeholder = "Re-enter your password"
    passConfirmField.isSecure = true
    passConfirmField:setReturnKey("done")

    group:insert(passLabel)
    group:insert(passField)
    group:insert(passConfirmLabel)
    group:insert(passConfirmField)

    group.passField = passField
    group.passConfirmField = passConfirmField

    return group
end

function scene:sanity_check_details()
    local group = self.view
    local username_text = group.username_text
    local username = username_text.text
    print ("Username entered = " .. username)

    local email_text = group.email_text
    local email = email_text.text
    print ("Email entered = " .. email) 

    local pass_fields = group.pass_fields
    local passField = pass_fields.passField
    local passConfirmField = pass_fields.passConfirmField

    local pass = passField.text
    local passConfirm = passConfirmField.text
    print ("Password entered = " .. pass)
    print ("Password confirm = " .. passConfirm)

    local errorMsg = nil;

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

local function create_account_success(user)
    print("Creating account was a success: " .. json.encode( user ))
    local currentSceneName = composer.getSceneName( "current" )
    composer.removeScene( currentSceneName, false )
    composer.gotoScene( "scenes.title_scene", "fade" )
end

local function create_account_fail()
    -- do nothing, a popup will appear anyway.
end


local function create_done_button()
    local doneButton = common_ui.create_button("Go!", 1050, function(event)
            local result = scene:sanity_check_details()
            if result["error"] ~= nil then
                native.showAlert( "Oops...", result["error"], { "Try again" } )
            else
                common_api.createNewAccountAndLogin(result["username"], result["email"], result["password"],
                    create_account_success, create_account_fail)
            end

        end)
    return doneButton
end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    local backButton = common_ui.create_back_button(100, 100)
    local usernameLabelGrp = create_username_label_and_desc()
    local username_text = create_username_text_field()
    local emailLabelGrp = create_email_label_and_desc()
    local email_text = create_email_text_field()
    local pass_fields = create_password_fields()
    local done_button = create_done_button()

    sceneGroup:insert(background)
    sceneGroup:insert(backButton)
    sceneGroup:insert(username_text)
    sceneGroup:insert(usernameLabelGrp)
    sceneGroup:insert(email_text)
    sceneGroup:insert(emailLabelGrp)
    sceneGroup:insert(pass_fields)
    sceneGroup:insert(done_button)

    sceneGroup.username_text = username_text
    sceneGroup.email_text = email_text
    sceneGroup.pass_fields = pass_fields

end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
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
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view
    sceneGroup.username_text:removeSelf( )
    sceneGroup.email_text:removeSelf( )
    sceneGroup.pass_fields:removeSelf( )

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