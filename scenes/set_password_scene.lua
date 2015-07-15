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
local nav = require("common.nav")

local scene = composer.newScene()
scene.sceneName = "scenes.set_password_scene"

-- "scene:create()"
function scene:create(event)

	local sceneGroup = self.view

    self.background = common_ui.createBackground()
    self.backButton = self:createBackButton()

    -- title & username
    self.titleText = self:drawTitleText()
    self.usernameText = self:drawUsernameText()

    -- password input 1
    self.passwordLabel1 = self:drawPasswordLabel1()

    -- password input 2
    self.passwordLabel2 = self:drawPasswordLabel2()

    self:createNativeInputs()

    -- submit button
    self.submitButton = self:drawSubmitButton()

    sceneGroup:insert(self.background)
    sceneGroup:insert(self.backButton)
    sceneGroup:insert(self.titleText)
    if self.usernameText then
        sceneGroup:insert(self.usernameText)
    end
    sceneGroup:insert(self.passwordLabel1)
    sceneGroup:insert(self.passwordLabel2)
    sceneGroup:insert(self.submitButton)

end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        local creds = login_common.fetchCredentials()
        if not creds or not creds.user then
            login_common.logout()
            return
        end
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
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
end

function scene:createBackButton()
    return common_ui.createBackButton(80, 120, "scenes.title_scene")
end

-- Draw username at the top
function scene:drawTitleText()
    local titleText = display.newText {
        text = "Setting password for...",
        x = display.contentCenterX,
        y = 200,
        font = fonts.DEFAULT_FONT,
        fontSize = 44
    }
    titleText:setFillColor(0, 0, 0)
    return titleText
end

function scene:drawUsernameText()
    local user = login_common.getUser()
    if not user or not user.username then
        composer.gotoScene("scenes.title_scene", "fade")
        return nil
    end
    local usernameText = display.newText {
        text = user.username,
        x = display.contentCenterX,
        y = 275,
        font = fonts.DEFAULT_FONT,
        fontSize = 48
    }
    usernameText:setFillColor(0, 0, 0)
    return usernameText
end

-- Draw text fields
function scene:drawPasswordLabel1()
    local labelText = display.newText {
        text = "Enter password",
        x = display.contentCenterX,
        y = 400,
        font = fonts.BOLD_FONT,
        fontSize = 52
    }
    labelText:setFillColor(0, 0, 0)

    return labelText
end

function scene:drawPasswordInput1()
    local function inputListener(event)
        if event.phase == "began" then

        elseif event.phase == "editing" then
            if event.text and event.text:len() > pass_helpers.MAX_PASSWORD_LEN then
                event.target.text = event.text:sub(1, pass_helpers.MAX_PASSWORD_LEN)
            end
        elseif event.phase == "submitted" then
            print("Submitted pass input...")
            if self.passwordInput2 and self.passwordInput2.textField then
                native.setKeyboardFocus(self.passwordInput2.textField)
            end
        elseif event.phase == "ended" then
        end
        return true
    end

    local customText = custom_text_field.newCustomTextField {
        align = "center",
        x = display.contentCenterX,
        y = 475,
        isSecure = true,
        backgroundColor = { 1, 1, 1, 0.5 },
        width = 550,
        height = 75,
        fontSize = 16,
        listener = inputListener,
        returnKey = "next"
    }

    return customText
end

function scene:drawPasswordLabel2()
    local labelText = display.newText {
        text = "Re-enter password",
        x = display.contentCenterX,
        y = 575,
        font = fonts.BOLD_FONT,
        fontSize = 52
    }
    labelText:setFillColor(0, 0, 0)

    return labelText
end

function scene:drawPasswordInput2()
    local function inputListener(event)
        if event.phase == "began" then

        elseif event.phase == "editing" then
            if event.text and event.text:len() > pass_helpers.MAX_PASSWORD_LEN then
                event.target.text = event.text:sub(1, pass_helpers.MAX_PASSWORD_LEN)
            end
        elseif event.phase == "submitted" then
            print("Submitted pass input 2...")
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
        fontSize = 16,
        returnKey = "done"
    }
    return customText
end

-- Submit !
function scene:submit()
    if not common_ui.isValidDisplayObj(self.passwordInput1) or not common_ui.isValidDisplayObj(self.passwordInput2) then
        print("[ERROR] Submitted set password when password inputs weren't defined.")
        return
    end

    local pass1 = self.passwordInput1:getText()
    local pass2 = self.passwordInput2:getText()

    local isValid, msg = pass_helpers.validatePassword(pass1, pass2)

    local function onCloseModal()
        self:createNativeInputs()
    end

    if not isValid then
        msg = msg or "Invalid passwords entered, please try again."
        self:destroyNativeInputs()
        common_ui.createInfoModal("Try again", msg, onCloseModal)
    else

        local function onSuccess()
            common_ui.createInfoModal("Success!", "You set a password. Now you can login on other devices.", onCloseModal);
            nav.goToSceneFrom(scene.sceneName, "scenes.title_scene", "fade")
        end

        local function onFail(jsonResp)
            local errorMsg = jsonResp and jsonResp["errorMessage"] or "An error occurred setting your password. Please try again"
            common_ui.createInfoModal("Oops...", errorMsg, onCloseModal)
        end

        self:destroyNativeInputs()
        common_api.setUserPassword(pass1, onSuccess, onFail, true)
    end

end

function scene:destroyNativeInputs()
    if self.passwordInput1 then
        self.passwordInput1:destroy()
    end
    if self.passwordInput2 then
        self.passwordInput2:destroy()
    end
end

function scene:createNativeInputs()
    self.passwordInput1 = self:drawPasswordInput1()
    self.passwordInput2 = self:drawPasswordInput2()
    self.view:insert(self.passwordInput1)
    self.view:insert(self.passwordInput2)
end

-- Draw submit button
function scene:drawSubmitButton()
    local function onRelease()
        self:submit()
    end

    local button = common_ui.createButton("Submit", 750, onRelease, 400, 100, 52)
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

