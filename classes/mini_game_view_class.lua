local display = require("display")
local native = require("native")
local json = require("json")
local common_ui = require("common.common_ui")
local time_util = require("common.time_util")
local mini_board_class = require("classes.mini_board_class")

local mini_game_view_class = {}
local mini_game_view_class_mt = { __index = mini_game_view_class }

-- Constants
local PAD = 10

function mini_game_view_class.new(index, gameModel, authUser, width, height, miniBoardWidth, titleFontSize, otherFontSize)
    if not gameModel or not authUser then
        print("ERROR - must provide non-nil gameModel and authUser")
        return nil
    end

    if authUser.id ~= gameModel.player1Model.id and authUser.id ~= gameModel.player2Model.id then
        print("The logged in user (" .. authUser.username .. ") isn't player 1 or player 2 in the given game: " .. json.encode(gameModel))
        return nil
    end

    local miniGameView = {
        index = index,
        gameModel = gameModel,
        authUser = authUser,
        width = width,
        height = height,
        miniBoardWidth = miniBoardWidth,
        titleFontSize = titleFontSize or 30,
        otherFontSize = otherFontSize or 24
    }

    return setmetatable(miniGameView, mini_game_view_class_mt)

end

-- Render the main display group, store as self.view
-- Returns self.view
function mini_game_view_class:render()
    local bg = self:renderBackground()
    bg.x = self.width / 2
    bg.y = 300

    local title = self:renderTitle()
    title.y = 50

    local pointsGroup = self:renderPointsDisplay()
    pointsGroup.y = 100

    local dateView = self:renderDateStarted()
    dateView.y = 150

    local miniBoardView = self:renderMiniBoardView()
    miniBoardView.y = 200 + self.miniBoardWidth / 2

    local group = display.newGroup()
    group.x = PAD
    group:insert(bg)
    group:insert(title)
    group:insert(pointsGroup)
    group:insert(dateView)
    group:insert(miniBoardView)

    self.view = group

    return group
end

function mini_game_view_class:destroy()
    if self.view then
        self.view:removeSelf()
        self.view = nil
    end
end

function mini_game_view_class:renderBackground()
    local imgFile
    if self.index % 2 == 0 then
        imgFile = "images/red_minigame_bg.jpg"
    else
        imgFile = "images/green_minigame_bg.jpg"
    end
    return display.newImageRect(imgFile, self.width, self.height)
end

function mini_game_view_class:renderTitle()
    local gameModel = self.gameModel
    local authUser = self.authUser
    local enemyUser
    if authUser.id == gameModel.player1Model.id then
        enemyUser = gameModel.player2Model
    else
        enemyUser = gameModel.player1Model
    end
    local titleTxt = "Me vs. " .. enemyUser.username
    return display.newText {
        text = titleTxt,
        fontSize = self.titleFontSize,
        font = native.systemFontBold,
        width = self.width,
        align = "center",
        x = self.width / 2
    }
end

function mini_game_view_class:renderPointsDisplay()
    local gameModel = self.gameModel
    local authUser = self.authUser
    local isPlayer1 = authUser.id == gameModel.player1Model.id
    local myPoints, enemyPoints, enemyName
    if isPlayer1 then
        myPoints, enemyPoints, enemyName = gameModel.player1Points, gameModel.player2Points, gameModel.player2Model.username
    else
        enemyPoints, enemyName, myPoints = gameModel.player1Points, gameModel.player1Model.username, gameModel.player2Points
    end
    local leftPointsTxt = "Me: " .. myPoints
    local rightPointsTxt = common_ui.truncateName(enemyName, 12) .. ": " .. enemyPoints

    local pointsGroup = display.newGroup()

    local leftText = display.newText {
        text = leftPointsTxt,
        font = native.systemFont,
        fontSize = self.otherFontSize,
        width = self.width / 2,
        align = "center",
        x = self.width / 4
    }

    local rightText = display.newText {
        text = rightPointsTxt,
        font = native.systemFont,
        fontSize = self.otherFontSize,
        width = self.width / 2,
        align = "center",
        x = 3 * self.width / 4
    }

    pointsGroup:insert(leftText)
    pointsGroup:insert(rightText)
    return pointsGroup
end

function mini_game_view_class:renderDateStarted()
    local gameModel = self.gameModel
    local startTimeSecs = gameModel.dateCreated / 1000
    local durationPretty = time_util.printDurationPrettyFromStartTime(startTimeSecs)
    local displayTxt = "Started " .. durationPretty
    return display.newText {
        text = displayTxt,
        fontSize = self.otherFontSize,
        font = native.systemFont,
        width = self.width,
        x = self.width / 2,
        align = "center"
    }
end

function mini_game_view_class:renderMiniBoardView()
    local miniBoardView = mini_board_class.new(self.gameModel, self.miniBoardWidth, PAD)
    self.miniBoardView = miniBoardView
    miniBoardView.boardGroup.x = self.width / 2
    return miniBoardView.boardGroup
end

return mini_game_view_class

