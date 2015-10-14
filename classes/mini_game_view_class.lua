local display = require("display")
local native = require("native")
local json = require("json")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local fonts = require("globals.fonts")
local game_ui = require("common.game_ui")
local nav = require("common.nav")
local composer = require("composer")
local widget = require("widget")
local time_util = require("common.time_util")
local mini_board_class = require("classes.mini_board_class")
local dict_helpers = require("common.dict_helpers")
local game_helpers = require("common.game_helpers")

local mini_game_view_class = {}
local mini_game_view_class_mt = { __index = mini_game_view_class }

-- Constants
local PAD = 10

function mini_game_view_class.new(index, gameModel, authUser, width, height, miniBoardWidth, titleFontSize, otherFontSize, scene,
                    isOfferedGame, onAccept, onReject)
    if not gameModel or not authUser then
        print("ERROR - must provide non-nil gameModel and authUser")
        return nil
    end

    if authUser.id ~= gameModel.player1Model.id and authUser.id ~= gameModel.player2Model.id then
        print("The logged in user (" .. tostring(authUser.username) .. ") isn't player 1 or player 2 in the given game: " .. json.encode(gameModel))
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
        scene = scene,
        isOfferedGame = isOfferedGame,
        onAccept = onAccept,
        onReject = onReject
    }

    return setmetatable(miniGameView, mini_game_view_class_mt)

end

-- Render the main display group, store as self.view
-- Returns self.view
function mini_game_view_class:render()
    local group = display.newGroup()

    local bg = self:renderBackground()
    bg.x = self.width / 2
    bg.y = 300

    self.title = self:renderTitle()
    self.title.y = 50

    local dateView = self:renderDateStarted()
    dateView.y = 150

    local miniBoardView = self:renderMiniBoardView()
    miniBoardView.y = 200 + self.miniBoardWidth / 2

    group.x = PAD
    group:insert(bg)
    group:insert(self.title)
    group:insert(dateView)
    group:insert(miniBoardView)

    local dictIndicator = self:drawDictIndicator()
    if dictIndicator then
        group:insert(dictIndicator)
    end

    if self.isOfferedGame then
        -- Render the accept/reject buttons
        self.acceptButton, self.rejectButton = self:renderAcceptAndRejectButtons()
        group:insert(self.acceptButton)
        group:insert(self.rejectButton)
    end

    self.view = group

    return group
end

function mini_game_view_class:drawDictIndicator()
    local imgFile = self:getDictImage()
    if not imgFile then
        return nil
    end
    local img = display.newImageRect(imgFile, 200, 233)
    img.x, img.y = img.contentWidth / 2, self.height / 2
    return img
end

function mini_game_view_class:getDictImage()
    local SPECIAL_DICT = self.gameModel and self.gameModel.specialDict
    return dict_helpers.getDictImageFile(SPECIAL_DICT)
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
    local gameInProgress = self.gameModel.gameResult == common_api.IN_PROGRESS or self.gameModel.gameResult == common_api.OFFERED
    local isMyTurn = game_helpers.isPlayerTurn(self.gameModel, self.authUser)
    if gameInProgress and isMyTurn then
        imgFile = "images/green_minigame_bg.jpg"
    elseif gameInProgress and not isMyTurn then
        imgFile = "images/red_minigame_bg.jpg"
    else
        imgFile = "images/red_minigame_bg.jpg"
    end
    return display.newImageRect(imgFile, self.width, self.height)
end

function mini_game_view_class:renderTitle()
    return game_ui.createVersusDisplayGroup(self.gameModel, self.authUser, self.scene, true,
        self.width / 4, self.width / 2, 3 * self.width / 4, -10, {1, 1, 1}, 275, true, true)
end

function mini_game_view_class:renderDateStarted()
    local gameModel = self.gameModel
    local startTimeSecs = gameModel.lastActivity / 1000
    local durationPretty = time_util.printDurationPrettyFromStartTime(startTimeSecs)
    local displayTxt = self.isOfferedGame and "Challenged " .. durationPretty or "Last move " .. durationPretty
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
    local miniBoardView = mini_board_class.new(self.gameModel, self.miniBoardWidth, 30, self.isOfferedGame)
    self.miniBoardView = miniBoardView
    miniBoardView.boardGroup.x = self.width / 2
    if not self.isOfferedGame then
        miniBoardView.boardGroup:addEventListener("touch", self)
    end
    return miniBoardView.boardGroup
end

function mini_game_view_class:renderAcceptAndRejectButtons()
    local acceptButton = widget.newButton {
        x = self.width / 4 + 20,
        y = self.height / 2,
        emboss = true,
        label = "Accept",
        font = fonts.BOLD_FONT,
        fontSize = 42,
        width = self.width / 3,
        height = self.height / 6,
        shape = "roundedRect",
        cornerRadius = 20,
        labelColor = { default = common_ui.BUTTON_LABEL_COLOR_DEFAULT, over = common_ui.BUTTON_LABEL_COLOR_OVER },
        fillColor = { default = common_ui.GREEN_FILL_COLOR_DEFAULT, over = common_ui.GREEN_FILL_COLOR_OVER },
        strokeColor = { default = common_ui.GREEN_STROKE_COLOR_DEFAULT, over = common_ui.GREEN_STROKE_COLOR_OVER },
        strokeWidth = 4,
        onRelease = self.onAccept
    }

    local rejectButton = widget.newButton {
        x = 3 * self.width / 4 - 20,
        y = self.height / 2,
        emboss = true,
        label = "Reject",
        font = fonts.BOLD_FONT,
        fontSize = 42,
        width = self.width / 3,
        height = self.height / 6,
        shape = "roundedRect",
        cornerRadius = 20,
        labelColor = { default = common_ui.BUTTON_LABEL_COLOR_DEFAULT, over = common_ui.BUTTON_LABEL_COLOR_OVER },
        fillColor = { default = common_ui.RED_FILL_COLOR_DEFAULT, over = common_ui.RED_FILL_COLOR_OVER },
        strokeColor = { default = common_ui.RED_STROKE_COLOR_DEFAULT, over = common_ui.RED_STROKE_COLOR_OVER },
        strokeWidth = 4,
        onRelease = self.onReject
    }

    return acceptButton, rejectButton
end

function mini_game_view_class:touch(event)
    if event.phase == "began" then
       display.getCurrentStage():setFocus(event.target)
       self.miniBoardView.boardGroup.alpha = 0.5
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

