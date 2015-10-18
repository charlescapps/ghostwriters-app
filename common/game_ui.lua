local display = require("display")
local native = require("native")
local transition = require("transition")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local user_info_popup = require("classes.user_info_popup")
local graphics = require("graphics")
local checkboxes_sheet = require("spritesheets.checkboxes_sheet")
local radio_button_sheet = require("spritesheets.radio_button_sheet")
local stepper_sheet = require("spritesheets.stepper_sheet")
local fonts = require("globals.fonts")
local timer = require("timer")
local points_ca_ching = require("classes.points_ca_ching")

local TROPHY_SIZE = 70
local HOURGLASS_SIZE = 70

local M = {}

function M.createVersusDisplayGroup(gameModel, authUser, scene, replaceNameWithMe, leftX, centerX, rightX, firstRowY, fontRgb, circleWidth, isCircleWhite, allowStartNewGame)
    fontRgb = fontRgb or { 0, 0, 0 }
    centerX = centerX or display.contentWidth / 2
    leftX = leftX or display.contentWidth / 4
    rightX = rightX or 3 * display.contentWidth / 4
    firstRowY = firstRowY or 80

    local authUserIsPlayer1 = gameModel.player1 == authUser.id
    local isAuthUserTurn = gameModel.player1Turn and authUserIsPlayer1 or not gameModel.player1Turn and not authUserIsPlayer1
    local player1 = gameModel.player1Model
    local player2 = gameModel.player2Model
    local leftUsername, rightUsername, leftPoints, rightPoints, leftFont, rightFont, leftPlayer, rightPlayer
    if authUserIsPlayer1 then
        if replaceNameWithMe then
            leftUsername = "Me"
        else
            leftUsername = player1.username
        end
        rightUsername = player2.username
        leftPlayer, rightPlayer = player1, player2
        leftPoints, rightPoints = gameModel.player1Points, gameModel.player2Points
    else
        if replaceNameWithMe then
            leftUsername = "Me"
        else
            leftUsername = player2.username
        end
        rightUsername = player1.username
        leftPlayer, rightPlayer = player2, player1
        leftPoints, rightPoints = gameModel.player2Points, gameModel.player1Points
    end

    -- Replace AI names by appending "(AI)"
    leftUsername = common_api.getUsernameForAI(leftUsername)
    rightUsername = common_api.getUsernameForAI(rightUsername)

    if gameModel.gameResult == common_api.IN_PROGRESS or gameModel.gameResult == common_api.OFFERED then
        if isAuthUserTurn then
            leftFont = fonts.BOLD_FONT
            rightFont = fonts.DEFAULT_FONT
        else
            leftFont = fonts.DEFAULT_FONT
            rightFont = fonts.BOLD_FONT
        end
    elseif (gameModel.gameResult == common_api.PLAYER1_WIN or gameModel.gameResult == common_api.PLAYER2_RESIGN)
                and leftPlayer.id == gameModel.player1 or
            (gameModel.gameResult == common_api.PLAYER2_WIN or gameModel.gameResult == common_api.PLAYER1_RESIGN)
                and leftPlayer.id == gameModel.player2 then
        leftFont = fonts.BOLD_FONT
        rightFont = fonts.DEFAULT_FONT
    elseif (gameModel.gameResult == common_api.PLAYER1_WIN or gameModel.gameResult == common_api.PLAYER2_RESIGN)
                and rightPlayer.id == gameModel.player1 or
            (gameModel.gameResult == common_api.PLAYER2_WIN or gameModel.gameResult == common_api.PLAYER1_RESIGN)
                and rightPlayer.id == gameModel.player2 then
        leftFont = fonts.DEFAULT_FONT
        rightFont = fonts.BOLD_FONT
    else
        leftFont = fonts.DEFAULT_FONT
        rightFont = fonts.DEFAULT_FONT
    end

    local group = display.newGroup( )

    -- The font size should be smaller if the username is over 11 characters
    local leftFontSize, rightFontSize = 44, 44
    if leftUsername:len() > 11 then
        leftFontSize = 34
    end
    if rightUsername:len() > 11 then
        rightFontSize = 34
    end

    -- Create the username texts
    local leftPlayerText = display.newText( {
        text = leftUsername,
        x = leftX,
        y = firstRowY,
        font = leftFont,
        fontSize = leftFontSize,
        align = "center"
    })
    leftPlayerText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )
    function leftPlayerText:touch(event)
        if event.phase == "ended" then
            group.leftUserInfoPopup = user_info_popup.new(leftPlayer, scene, authUser, allowStartNewGame)
            scene.view:insert(group.leftUserInfoPopup:render())
        end
        return true
    end
    leftPlayerText:addEventListener("touch")

    local rightPlayerText = display.newText( {
        text = rightUsername,
        x = rightX,
        y = firstRowY,
        font = rightFont,
        fontSize = rightFontSize,
        align = "center" })
    rightPlayerText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )
    function rightPlayerText:touch(event)
        if event.phase == "ended" then
            group.rightUserInfoPopup = user_info_popup.new(rightPlayer, scene, authUser, allowStartNewGame)
            scene.view:insert(group.rightUserInfoPopup:render())
        end
        return true
    end
    rightPlayerText:addEventListener("touch")

    -- Create vs. text
    local versusText = display.newText("vs.", centerX, firstRowY, fonts.BOLD_FONT, 50 )
    versusText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )

    local pointsY = firstRowY + 60
    local trophyY = pointsY - 8
    -- Create point displays
    local leftPointsText = points_ca_ching.new { x = leftX, y = pointsY, points = leftPoints }
    local rightPointsText = points_ca_ching.new { x = rightX, y = pointsY, points = rightPoints }

    group.leftPointsText, group.rightPointsText = leftPointsText, rightPointsText
    group.leftPlayerText, group.rightPlayerText = leftPlayerText, rightPlayerText

    group:insert(leftPlayerText)
    group:insert(rightPlayerText)
    group:insert(versusText)
    group:insert(leftPointsText:render())
    group:insert(rightPointsText:render())

    -- If the game is in progress, draw a circle around the current user
    if gameModel.gameResult == common_api.IN_PROGRESS or gameModel.gameResult == common_api.OFFERED then
        circleWidth = circleWidth or 300
        local circleImage = isCircleWhite and "images/pencil-white-circled.png" or "images/pencil-circled.png"
        local leftCircle = display.newImageRect(circleImage, circleWidth, 75)
        leftCircle.x, leftCircle.y, leftCircle.alpha = leftX, firstRowY, 0

        local rightCircle = display.newImageRect(circleImage, circleWidth, 75)
        rightCircle.x, rightCircle.y, rightCircle.alpha = rightX, firstRowY, 0

        -- Store the circles in group object for later use
        group.leftCircle, group.rightCircle = leftCircle, rightCircle

        if isAuthUserTurn then
            leftCircle.alpha = 1
        else
            rightCircle.alpha = 1
        end

        group:insert(leftCircle)
        group:insert(rightCircle)

    elseif authUserIsPlayer1 and (gameModel.gameResult == common_api.PLAYER1_WIN or gameModel.gameResult == common_api.PLAYER2_RESIGN) or
            not authUserIsPlayer1 and (gameModel.gameResult == common_api.PLAYER2_WIN or gameModel.gameResult == common_api.PLAYER1_RESIGN) then
        -- draw the trophy on the left player
        local trophyImg = display.newImageRect("images/trophy_gold.png", TROPHY_SIZE, TROPHY_SIZE)
        trophyImg.anchorX = 1
        trophyImg.x = leftPointsText.view.x - leftPointsText.view.contentWidth / 2 - 2
        trophyImg.y = trophyY
        group:insert(trophyImg)

    elseif authUserIsPlayer1 and (gameModel.gameResult == common_api.PLAYER2_WIN or gameModel.gameResult == common_api.PLAYER1_RESIGN) or
            not authUserIsPlayer1 and (gameModel.gameResult == common_api.PLAYER1_WIN or gameModel.gameResult == common_api.PLAYER2_RESIGN) then

        -- draw the trophy on the right player
        local trophyImg = display.newImageRect("images/trophy_gold.png", TROPHY_SIZE, TROPHY_SIZE)
        trophyImg.anchorX = 1
        trophyImg.x = rightPointsText.view.x - rightPointsText.view.contentWidth / 2 - 2
        trophyImg.y = trophyY
        group:insert(trophyImg)

    elseif authUserIsPlayer1 and gameModel.gameResult == common_api.PLAYER1_TIMEOUT or
            not authUserIsPlayer1 and gameModel.gameResult == common_api.PLAYER2_TIMEOUT then
        -- draw the trophy on the left player
        local hourglassImg = display.newImageRect("images/timed_out_icon.png", HOURGLASS_SIZE, HOURGLASS_SIZE)
        hourglassImg.anchorX = 1
        hourglassImg.x = leftPointsText.view.x - leftPointsText.view.contentWidth / 2 - 4
        hourglassImg.y = trophyY
        group:insert(hourglassImg)

    elseif authUserIsPlayer1 and gameModel.gameResult == common_api.PLAYER2_TIMEOUT or
            not authUserIsPlayer1 and gameModel.gameResult == common_api.PLAYER1_TIMEOUT then

        -- draw the trophy on the right player
        local hourglassImg = display.newImageRect("images/timed_out_icon.png", HOURGLASS_SIZE, HOURGLASS_SIZE)
        hourglassImg.anchorX = 1
        hourglassImg.x = rightPointsText.view.x - rightPointsText.view.contentWidth / 2 - 4
        hourglassImg.y = trophyY
        group:insert(hourglassImg)

    elseif gameModel.gameResult == common_api.TIE then

        local tieText = display.newText {
            text = "TIE!",
            font = fonts.BOLD_FONT,
            fontSize = 40,
            x = centerX,
            y = pointsY
        }
        tieText:setFillColor(fontRgb[1], fontRgb[2], fontRgb[3])
        group:insert(tieText)

    end

    -- Add a method to destroy the modals
    function group:destroyUserInfoPopups()
        if self.leftUserInfoPopup then
            self.leftUserInfoPopup:destroy()
        end

        if self.rightUserInfoPopup then
            self.rightUserInfoPopup:destroy()
        end
    end

    return group
end

function M.createRatingUpModal(parentScene, ratingChange, onClose)
    local group = display.newGroup()
    group.x, group.y = display.contentWidth / 2, display.contentHeight / 2
    group.alpha = 0

    local background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    background:setFillColor(0, 0, 0, 0.5)

    local modalImage = display.newImageRect(group, "images/rating_up_modal.png", 750, 750)

    local ratingText = display.newText {
        parent = group,
        x = 0,
        y = -150,
        text = "+" .. tostring(ratingChange),
        width = 300,
        height = 125,
        font = native.systemBoldFont,
        fontSize = 90,
        align = "center"
    }
    ratingText:setFillColor(0, 0, 0)

    local onComplete = function()
        common_ui.safeRemove(group)
        if onClose and not group.ranOnClose then
            onClose()
            group.ranOnClose = true
        end
    end

    local onCancel = function()
        common_ui.safeRemove(group)
    end

    group:insert(background)
    group:insert(modalImage)
    group:insert(ratingText)

    local function close()
        if not common_ui.isValidDisplayObj(group) then
            return
        end

        transition.cancel(group)
        transition.fadeOut(group, {
            onComplete = onComplete,
            onCancel = onCancel
        })
    end

    background:addEventListener("touch", function(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            close()
        end
        return true
    end)

    local function onFadeInComplete()
        timer.performWithDelay(3000, close)
    end

    transition.fadeIn(group, { time = 1000, onComplete = onFadeInComplete, onCancel = onFadeInComplete })

    return group
end

function M:getRadioButtonSheet()
    if not self.radioButtonSheet then
        self.radioButtonSheet = graphics.newImageSheet("spritesheets/radio_button_sheet.png", radio_button_sheet:getSheet())
    end
    return self.radioButtonSheet
end

function M:getCheckboxesSheet()
    if not self.checkboxesSheet then
        self.checkboxesSheet = graphics.newImageSheet("spritesheets/checkboxes_sheet.png", checkboxes_sheet:getSheet())
    end
    return self.checkboxesSheet
end

function M:getStepperSheet()
    if not self.stepperSheet then
       self.stepperSheet = graphics.newImageSheet("spritesheets/stepper_sheet.png", stepper_sheet:getSheet())
    end
    return self.stepperSheet
end

return M

