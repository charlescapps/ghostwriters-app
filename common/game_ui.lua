local display = require("display")
local native = require("native")
local transition = require("transition")
local common_api = require("common.common_api")
local user_info_popup = require("classes.user_info_popup")
local graphics = require("graphics")
local checkboxes_sheet = require("spritesheets.checkboxes_sheet")
local radio_button_sheet = require("spritesheets.radio_button_sheet")
local stepper_sheet = require("spritesheets.stepper_sheet")


local M = {}

function M.createVersusDisplayGroup(gameModel, authUser, scene, replaceNameWithMe, leftX, centerX, rightX, firstRowY, fontRgb, circleWidth, allowStartNewGame)
    fontRgb = fontRgb or { 0, 0, 0 }
    centerX = centerX or display.contentWidth / 2
    leftX = leftX or display.contentWidth / 4
    rightX = rightX or 3 * display.contentWidth / 4
    firstRowY = firstRowY or 100

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

    if isAuthUserTurn then
        leftFont = native.systemFontBold
        rightFont = native.systemFont
    else
        leftFont = native.systemFont
        rightFont = native.systemFontBold
    end

    local group = display.newGroup( )

    -- The font size should be smaller if the username is over 11 characters
    local leftFontSize, rightFontSize = 40, 40
    if leftUsername:len() > 11 then
        leftFontSize = 30
    end
    if rightUsername:len() > 11 then
        rightFontSize = 30
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
    local versusText = display.newText("vs.", centerX, firstRowY, native.systemFontBold, 50 )
    versusText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )

    local pointsY = firstRowY + 50
    -- Create point displays
    local leftPointsText = display.newText( leftPoints .. " points", leftX, pointsY, native.systemFontBold, 30 )
    leftPointsText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )
    function leftPointsText:setPoints(points)
        self.text = points .. " points"
    end

    local rightPointsText = display.newText( rightPoints .. " points", rightX, pointsY, native.systemFontBold, 30 )
    rightPointsText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )
    function rightPointsText:setPoints(points)
        self.text = points .. " points"
    end

    group.leftPointsText, group.rightPointsText = leftPointsText, rightPointsText
    group.leftPlayerText, group.rightPlayerText = leftPlayerText, rightPlayerText

    group:insert(leftPlayerText)
    group:insert(rightPlayerText)
    group:insert(versusText)
    group:insert(leftPointsText)
    group:insert(rightPointsText)

    -- If the game is in progress, draw a circle around the current user
    if gameModel.gameResult == common_api.IN_PROGRESS or gameModel.gameResult == common_api.OFFERED then
        circleWidth = circleWidth or 300
        local leftCircle = display.newImageRect("images/pencil-circled.png", circleWidth, 75)
        leftCircle.x, leftCircle.y, leftCircle.alpha = leftX, firstRowY, 0

        local rightCircle = display.newImageRect("images/pencil-circled.png", circleWidth, 75)
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

    elseif authUserIsPlayer1 and gameModel.gameResult == common_api.PLAYER1_WIN or
            not authUserIsPlayer1 and gameModel.gameResult == common_api.PLAYER2_WIN then
        -- draw the trophy on the left player
        local trophyImg = display.newImageRect("images/trophy.png", 64, 64)
        trophyImg.x = 60
        trophyImg.y = pointsY
        group:insert(trophyImg)

    elseif authUserIsPlayer1 and gameModel.gameResult == common_api.PLAYER2_WIN or
            not authUserIsPlayer1 and gameModel.gameResult == common_api.PLAYER1_WIN then

        -- draw the trophy on the right player
        local trophyImg = display.newImageRect("images/trophy.png", 64, 64)
        trophyImg.x = centerX + 60
        trophyImg.y = pointsY
        group:insert(trophyImg)

    elseif gameModel.gameResult == common_api.TIE then

        local tieText = display.newText {
            text = "TIE!",
            font = native.systemFontBold,
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

function M.createRatingUpModal(parentScene, ratingChange)
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
        group:removeSelf()
    end

    local onCancel = function()
        group:removeSelf()
    end

    group:insert(background)
    group:insert(modalImage)
    group:insert(ratingText)

    background:addEventListener("touch", function(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            transition.fadeOut(group, {
                onComplete = onComplete,
                onCancel = onCancel
            })
        end
        return true
    end)

    transition.fadeIn(group, { time = 1000 })

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

