local widget = require("widget")
local common_ui = require("common.common_ui")
local display = require("display")
local native = require("native")
local transition = require("transition")
local composer = require("composer")
local mini_game_view_class = require("classes.mini_game_view_class")

local my_challengers_view_class = {}
local my_challengers_view_class_mt = { __index = my_challengers_view_class }

-- Constants
local PAD = 10
local MINI_GAME_WIDTH = display.contentWidth - PAD * 2
local MINI_GAME_HEIGHT = 600
local MINI_BOARD_WIDTH = 350

function my_challengers_view_class.new(authUser, challengedToMe, scene)
    local myGamesView = {
        authUser = authUser,
        challengedToMe = challengedToMe,
        scene = scene,
        miniGameViews = {}
    }
    return setmetatable(myGamesView, my_challengers_view_class_mt)
end

function my_challengers_view_class:setGames(games)
    print("my_challengers_view_class:setting games to array of size: " .. #(games.list))
    self.games = games
end

function my_challengers_view_class:render()
    print("Rendering My Games view...")
    local group = display.newGroup()

    local title = self:renderTitle()

    if self.games and self.games.list and #(self.games.list) > 0 then
        self.tableView = self:renderTableView()
        self:createMiniGames()
        for i = 1, #(self.games.list) do
            print("Inserting row: " .. i)
            self.tableView:insertRow {
                rowHeight = MINI_GAME_HEIGHT + PAD,
                isCategory = false,
                rowColor = { default = { 0.3, 0.3, 0.3, 0 }, over = { 0.3, 0.3, 0.3, 0.2 } }
            }
        end
        group:insert(self.tableView)
    else
        self.emptyGamesGroup = self:renderEmptyGamesGroup()
        group:insert(self.emptyGamesGroup)
    end

    group:insert(title)

    self.view = group
    return group
end

function my_challengers_view_class:destroy()
    if self.miniGameViews then
        for i = 1, #(self.miniGameViews) do
            if self.miniGameViews[i] then
                self.miniGameViews[i]:destroy()
            end
        end
    end
    if self.view then
        self.view:removeSelf()
    end
    self.view, self.games = nil, nil
end

function my_challengers_view_class:renderTitle()
    local titleText
    if self.challengedToMe then
        titleText = "My Challengers"
    else
        titleText = "Started by Me"
    end
    local title = display.newText {
        text = titleText,
        x = display.contentWidth / 2,
        y = 120,
        width = display.contentWidth,
        align = "center",
        font = native.systemFontBold,
        fontSize = 40
    }
    title:setFillColor(0, 0, 0)
    return title
end

function my_challengers_view_class:renderEmptyGamesGroup()
    local group = display.newGroup()
    group.x = display.contentWidth / 2
    group.y = display.contentHeight / 2
    local message
    if self.challengedToMe then
        message = "No challengers yet!"
    else
        message = "You haven't challenged any players!"
    end
    local messageText = display.newText {
        text = message,
        width = 7 * display.contentWidth / 8,
        align = "center",
        font = native.systemFont,
        fontSize = 52
    }
    messageText:setFillColor(0, 0, 0)

    local linkText = common_ui.createLink("Start a new game!", 0, 100, nil, function()
        composer.gotoScene("scenes.title_scene")
    end)

    group:insert(messageText)
    group:insert(linkText)
    return group
end

function my_challengers_view_class:renderTableView()
    return widget.newTableView {
        x = display.contentWidth / 2,
        y = display.contentHeight / 2 + 90,
        width = display.contentWidth,
        height = display.contentHeight - 180,
        onRowRender = self:createOnRowRenderListener(),
        backgroundColor = { 1, 1, 1, 0 },
        hideBackground = true,
        hideScrollbar = true
    }
end

function my_challengers_view_class:createMiniGames()
    local games = self.games
    if not games or not games.list then
        return
    end
    for i = 1, #(games.list) do
        local miniGameView = mini_game_view_class.new(i, games.list[i], self.authUser, MINI_GAME_WIDTH, MINI_GAME_HEIGHT, MINI_BOARD_WIDTH, 50, 40, self.scene, true)
        self.miniGameViews[i] = miniGameView
    end
end

function my_challengers_view_class:createOnRowRenderListener()
    return function(event)
        local games = self.games
        if not games or not games.list then
            return
        end

        local row = event.row
        local index = row.index

        if not games.list[index] then
            print("games[" .. index .. "] is not defined, so not rendering a row.")
            return
        end

        local miniGameView = self.miniGameViews[index]

        miniGameView:render()
        local miniGameViewGroup = miniGameView.view
        miniGameViewGroup.alpha = 0
        miniGameViewGroup.x = PAD

        row:insert(miniGameViewGroup)
        transition.fadeIn(miniGameViewGroup, { time = 2000 })
    end
end

return my_challengers_view_class
