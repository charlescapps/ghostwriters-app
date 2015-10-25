local composer = require( "composer" )
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local custom_text_field = require("classes.custom_text_field")
local display = require("display")
local login_common = require("login.login_common")
local scene_helpers = require("common.scene_helpers")
local fonts = require("globals.fonts")
local native = require("native")
local pass_helpers = require("common.pass_helpers")
local one_signal_util = require("push.one_signal_util")

local scene = composer.newScene()
scene.sceneName = "login.login_with_password_scene"

local MAX_USERNAME_LEN = 16

-- "scene:create()"
function scene:create(event)

	local sceneGroup = self.view

    self.background = common_ui.createBackground()
    self.backButton = self:createBackButton()

    -- title & username
    self.titleText = self:drawTitleText()

    -- password input 1
    self.usernameLabel = self:drawUsernameLabel()

    -- password input 2
    self.passwordLabel = self:drawPasswordLabel()

    -- submit button
    self.submitButton = self:drawSubmitButton()

    sceneGroup:insert(self.background)
    sceneGroup:insert(self.backButton)
    sceneGroup:insert(self.titleText)
    if self.usernameText then
        sceneGroup:insert(self.usernameText)
    end
    sceneGroup:insert(self.usernameLabel)
    sceneGroup:insert(self.passwordLabel)
    sceneGroup:insert(self.submitButton)

    self:createNativeInputs()

end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        scene_helpers.onDidShowScene(self)
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        self:destroyNativeInputs()
        scene_helpers.onWillHideScene(self)
    elseif ( phase == "did" ) then
        self.view = nil
        composer.removeScene(self.sceneName, false)
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
end

function scene:createBackButton()
    local user = login_common.getUser()
    if user then
        return common_ui.createBackButton(80, 120, "login.welcome_scene")
    else
        return common_ui.createBackButton(80, 120, "login.create_user_scene")
    end
end

-- Draw username at the top
function scene:drawTitleText()
    local titleText = display.newText {
        text = "Login to Ghostwriters",
        x = display.contentCenterX,
        y = 250,
        font = fonts.DEFAULT_FONT,
        fontSize = 56
    }
    titleText:setFillColor(0, 0, 0)
    return titleText
end

-- Draw text fields
function scene:drawUsernameLabel()
    local labelText = display.newText {
        text = "Username",
        x = display.contentCenterX,
        y = 400,
        font = fonts.BOLD_FONT,
        fontSize = 52
    }
    labelText:setFillColor(0, 0, 0)

    return labelText
end

function scene:drawUsernameInput()
    local function inputListener(event)
        if event.phase == "began" then

        elseif event.phase == "editing" then
            if event.text then
                event.target.text = pass_helpers.processUsername(event.text)
            end
        elseif event.phase == "submitted" then
            print("Submitted username input...")
            if self.passwordInput and self.passwordInput.textField then
                native.setKeyboardFocus(self.passwordInput.textField)
            end
        elseif event.phase == "ended" then
        end
        return true
    end

    local customText = custom_text_field.newCustomTextField {
        align = "center",
        x = display.contentCenterX,
        y = 475,
        backgroundColor = { 1, 1, 1, 0.5 },
        width = 550,
        height = 75,
        fontSize = nil,
        listener = inputListener,
        returnKey = "next"
    }

    local user = login_common.getUser()

    if user and user.username then
       customText:setText(user.username)
    end

    return customText
end

function scene:drawPasswordLabel()
    local labelText = display.newText {
        text = "Password",
        x = display.contentCenterX,
        y = 575,
        font = fonts.BOLD_FONT,
        fontSize = 52
    }
    labelText:setFillColor(0, 0, 0)

    return labelText
end

function scene:drawPasswordInput()
    local function inputListener(event)
        if event.phase == "began" then

        elseif event.phase == "editing" then
            if event.text and event.text:len() > pass_helpers.MAX_PASSWORD_LEN then
                event.target.text = event.text:sub(1, pass_helpers.MAX_PASSWORD_LEN)
            end
        elseif event.phase == "submitted" then
            print("Submitted password input...")
            self:submit()
        elseif event.phase == "ended" then
        end
        return true
    end

    local customText = custom_text_field.newCustomTextField {
        align = "center",
        x = display.contentCenterX,
        y = 650,
        isSecure = true,
        backgroundColor = { 1, 1, 1, 0.5 },
        width = 550,
        height = 75,
        returnKey = "done",
        listener = inputListener
    }
    return customText
end

-- Submit !
function scene:submit()
    native.setKeyboardFocus(nil)

    if not common_ui.isValidDisplayObj(self.usernameInput) or not common_ui.isValidDisplayObj(self.passwordInput) then
        print("[ERROR] Submitted set password when password inputs weren't defined.")
        return
    end

    local username = self.usernameInput:getText()
    local pass = self.passwordInput:getText()

    if not username or username:len() <= 0 then
        self:fadeOutNativeInputs()
        common_ui.createInfoModal("Enter a username", nil, function() self:fadeInNativeInputs() end)
        return
    end

    if not pass or pass:len() <= 0 then
        self:fadeOutNativeInputs()
        common_ui.createInfoModal("Enter a password", nil, function() self:fadeInNativeInputs() end)
        return
    end

    local function onSuccess()
        composer.gotoScene("scenes.title_scene", "fade")

        -- If user logs in as a different user, we need to call this so that
        -- OneSignal will send us the player_id for the phone, and then we can
        -- update the Ghostwriters server with the correct one signal ID for this user.
        one_signal_util.setIdsAvailableCallback()
    end

    local function onFail()
        self:fadeInNativeInputs()
    end

    self:fadeOutNativeInputs()
    common_api.login(username, pass, onSuccess, onFail, true)

end

function scene:fadeOutNativeInputs()
    if common_ui.isValidDisplayObj(self.usernameInput) and common_ui.isValidDisplayObj(self.passwordInput) then
        self.usernameInput:fadeOut()
        self.passwordInput:fadeOut()
    end
end

function scene:fadeInNativeInputs()
    if common_ui.isValidDisplayObj(self.usernameInput) and common_ui.isValidDisplayObj(self.passwordInput) then
        self.usernameInput:fadeIn()
        self.passwordInput:fadeIn()
    else
        self:createNativeInputs()
    end
end

function scene:destroyNativeInputs()
    if self.usernameInput then
        self.usernameInput:destroy()
    end
    if self.passwordInput then
        self.passwordInput:destroy()
    end
end

function scene:createNativeInputs()
    self.usernameInput = self:drawUsernameInput()
    self.passwordInput = self:drawPasswordInput()
    self.view:insert(self.usernameInput)
    self.view:insert(self.passwordInput)
end

-- Draw submit button
function scene:drawSubmitButton()
    local function onRelease()
        self:submit()
        return true
    end

    local button = common_ui.createButton("Login", 750, onRelease, 400, 100, 52)
    button.x = display.contentCenterX
    button.y = 775

    return button
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

