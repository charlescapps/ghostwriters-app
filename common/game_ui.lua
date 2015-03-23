local display = require("display")
local native = require("native")


local M = {}

function M.createVersusDisplayGroup(gameModel, authUser, replaceNameWithMe, leftX, rightX, firstRowY, fontRgb)
    fontRgb = fontRgb or { 0, 0, 0 }
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

    -- The actual displayed username text
    if leftUsername:len() > 11 then
        leftUsername = leftUsername:sub(1, 11) .. ".."
    end
    if rightUsername:len() > 11 then
        rightUsername = rightUsername:sub(1, 11) .. ".."
    end

    leftX = leftX or 175
    rightX = rightX or 575
    firstRowY = firstRowY or 100
    -- Create the username texts
    local leftPlayerText = display.newText( {
        text = leftUsername,
        x = leftX,
        y = firstRowY,
        font = leftFont,
        fontSize = 40,
        width = 400,
        height = 50,
        align = "center"
    })
    leftPlayerText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )

    local rightPlayerText = display.newText( {
        text = rightUsername,
        x = rightX,
        y = firstRowY,
        font = rightFont,
        fontSize = 40,
        width = 400, height = 50,
        align = "center" })
    rightPlayerText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )

    -- Create sparkles
    local leftSparkles = display.newImageRect("images/pencil-circled.png", 325, 75)
    leftSparkles.x, leftSparkles.y, leftSparkles.alpha = leftX, firstRowY, 0

    local rightSparkles = display.newImageRect("images/pencil-circled.png", 325, 75)
    rightSparkles.x, rightSparkles.y, rightSparkles.alpha = rightX, firstRowY, 0

    -- Create vs. text
    local versusText = display.newText("vs.", display.contentWidth / 2, firstRowY, native.systemFontBold, 50 )
    versusText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )

    local pointsY = firstRowY + 50
    -- Create point displays
    local leftPointsText = display.newText( "( " .. leftPoints .. " points )", leftX, pointsY, native.systemFontBold, 30 )
    leftPointsText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )
    function leftPointsText:setPoints(points)
        self.text = "( " .. points .. " points )"
    end

    local rightPointsText = display.newText( "( " .. rightPoints .. " points )", rightX, pointsY, native.systemFontBold, 30 )
    rightPointsText:setFillColor( fontRgb[1], fontRgb[2], fontRgb[3] )
    function rightPointsText:setPoints(points)
        self.text = "( " .. points .. " points )"
    end

    group:insert(leftPlayerText)
    group:insert(rightPlayerText)
    group:insert(versusText)
    group:insert(leftPointsText)
    group:insert(rightPointsText)
    group:insert(leftSparkles)
    group:insert(rightSparkles)

    -- Store sparkles in group object for later use
    group.leftSparkles, group.rightSparkles = leftSparkles, rightSparkles
    group.leftPointsText, group.rightPointsText = leftPointsText, rightPointsText

    if isAuthUserTurn then
        leftSparkles.alpha = 1
    else
        rightSparkles.alpha = 1
    end

    return group
end


return M

