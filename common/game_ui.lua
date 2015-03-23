local display = require("display")
local native = require("native")
local common_api = require("common.common_api")


local M = {}

function M.createVersusDisplayGroup(gameModel, authUser, replaceNameWithMe, leftX, centerX, rightX, firstRowY, fontRgb, circleWidth)
    fontRgb = fontRgb or { 0, 0, 0 }
    centerX = centerX or display.contentWidth / 2
    leftX = leftX or display.contentWidth / 4
    rightX = rightX or 3 * display.contentWidth / 4
    firstRowY = firstRowY or 100

    local authUserIsPlayer1 = gameModel.player1 == authUser.id
    local isAuthUserTurn = gameModel.player1Turn and authUserIsPlayer1 or not gameModel.player1Turn and not authUserIsPlayer1
    local player1 = gameModel.player1Model
    local player2 = gameModel.player2Model
    local leftUsername, rightUsername, leftPoints, rightPoints, leftFont, rightFont
    if authUserIsPlayer1 then
        if replaceNameWithMe then
            leftUsername = "Me"
        else
            leftUsername = player1.username
        end
        rightUsername = player2.username
        leftPoints, rightPoints = gameModel.player1Points, gameModel.player2Points
    else
        if replaceNameWithMe then
            leftUsername = "Me"
        else
            leftUsername = player2.username
        end
        rightUsername = player1.username
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

    local rightPlayerText = display.newText( {
        text = rightUsername,
        x = rightX,
        y = firstRowY,
        font = rightFont,
        fontSize = rightFontSize,
        align = "center" })
    rightPlayerText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )

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

    group:insert(leftPlayerText)
    group:insert(rightPlayerText)
    group:insert(versusText)
    group:insert(leftPointsText)
    group:insert(rightPointsText)

    -- If the game is in progress, draw a circle around the current user
    if gameModel.gameResult == common_api.IN_PROGRESS then
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
        local trophyImg = display.newImageRect("images/trophy.png", 75, 75)
        trophyImg.x = 40
        trophyImg.y = pointsY
        group:insert(trophyImg)

    elseif authUserIsPlayer1 and gameModel.gameResult == common_api.PLAYER2_WIN or
            not authUserIsPlayer1 and gameModel.gameResult == common_api.PLAYER1_WIN then

        -- draw the trophy on the right player
        local trophyImg = display.newImageRect("images/trophy.png", 75, 75)
        trophyImg.x = centerX + 75
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

    return group
end


return M

