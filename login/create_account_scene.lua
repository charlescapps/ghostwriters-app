local composer = require( "composer" )
local widget = require( "widget" )
local common_ui = require("common.common_ui")
local scene = composer.newScene()


local function create_username_text_field()
    local textField = native.newTextField( display.contentWidth / 2, 300, 600, 80 )
    textField.size = 20
    textField.placeholder = "Choose your username"
    textField:setReturnKey("next")
    return textField
end

local function create_email_text_field()
    local textField = native.newTextField( display.contentWidth / 2, 450, 600, 80 )
    textField.size = 20
    textField.placeholder = "Enter a valid email"
    textField:setReturnKey("next")
    return textField
end

local function create_password_fields()
    local group = display.newGroup( )
    local passLabel = display.newText( "Enter a password", display.contentWidth / 2, 650, native.systemBoldFont, 40 )
    passLabel:setFillColor( 0, 0, 0 )
    
    local passField = native.newTextField( display.contentWidth / 2, 725, 600, 80 )
    passField.size = 20
    passField.placeholder = "Enter your password"
    passField.isSecure = true
    passField:setReturnKey("next")


    local passConfirmLabel = display.newText( "Re-enter your password", display.contentWidth / 2, 825, native.systemBoldFont, 40 )
    passConfirmLabel:setFillColor( 0, 0, 0 )
    
    local passConfirmField = native.newTextField( display.contentWidth / 2, 900, 600, 80 )
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


local function create_done_button()
    local doneButton = common_ui.create_button("Go!", "create_account_done_button", 1050, function(event)
            if ( "ended" == event.phase ) then
                print( "Button was pressed and released" )
                validateResult = scene:sanity_check_details()
                if validateResult["error"] ~= nil then
                        native.showAlert( "Ooops...", validateResult["error"] )
                else
                end
            end

        end)
    return doneButton
end

-- "scene:create()"
function scene:create(event)
	local sceneGroup = self.view
    local background = common_ui.create_background()
    local username_text = create_username_text_field()
    local email_text = create_email_text_field()
    local pass_fields = create_password_fields()
    local done_button = create_done_button()

    sceneGroup:insert(background)
    sceneGroup:insert(username_text)
    sceneGroup:insert(email_text)
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