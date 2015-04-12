local display = require("display")
local native = require("native")
local json = require("json")
local common_ui = require("common.common_ui")
local game_ui = require("common.game_ui")
local nav = require("common.nav")
local composer = require("composer")
local time_util = require("common.time_util")
local mini_board_class = require("classes.mini_board_class")

local mini_game_view_class = {}
local mini_game_view_class_mt = { __index = mini_game_view_class }

-- Constants
local PAD = 10

function mini_game_view_class.new(index, gameModel, authUser, width, height, miniBoardWidth, titleFontSize, otherFontSize, scene)
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
        otherFontSize = otherFontSize or 24,
        scene = scene
    }

    return setmetatable(miniGameView, mini_game_view_class_mt)

end

-- Render the main display group, store as self.view
-- Returns self.view
function mini_game_view_class:render()
    local bg = self:renderBackground()
    bg.x = self.width / 2
    bg.y = 300

    self.title = self:renderTitle()
    self.title.y = 50

    local dateView = self:renderDateStarted()
    dateView.y = 150

    local miniBoardView = self:renderMiniBoardView()
    miniBoardView.y = 200 + self.miniBoardWidth / 2

    local group = display.newGroup()
    group.x = PAD
    group:insert(bg)
    group:insert(self.title)
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

    if self.title then
        self.title:destroyUserInfoPopups()
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
    return game_ui.createVersusDisplayGroup(self.gameModel, self.authUser, self.scene, true,
        self.width / 4, self.width / 2, 3 * self.width / 4, 0, {1, 1, 1}, 275, true)
end

function mini_game_view_class:renderDateStarted()
    local gameModel = self.gameModel
    local startTimeSecs = gameModel.dateCreated / 1000
    local durationPretty = time_util.printDurationPrettyFromStartTime(startTimeSecs)
    local displayTxt = "Last move " .. durationPretty
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
    local miniBoardView = mini_board_class.new(self.gameModel, self.miniBoardWidth, 30)
    self.miniBoardView = miniBoardView
    miniBoardView.boardGroup.x = self.width / 2
    miniBoardView.boardGroup:addEventListener("touch", self)
    return miniBoardView.boardGroup
end

function mini_game_view_class:touch(event)
    if event.phase == "began" then
       display.getCurrentStage():setFocus(event.target)
       self.miniBoardView.boardGroup.alpha = 0.75
       return true
    elseif event.phase == "ended" then
        display.getCurrentStage():setFocus(nil)
        self.miniBoardView.boardGroup.alpha = 1
        local currentScene = composer.getSceneName("current")
        nav.goToGame(self.gameModel, self.scene.sceneName)
        return true
    elseif event.phase == "cancelled" then
        display.getCurrentStage():setFocus(nil)
        self.miniBoardView.boardGroup.alpha = 1
        return true
    end
end

return mini_game_view_class

