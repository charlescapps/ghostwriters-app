local widget = require("widget")
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local fonts = require("globals.fonts")
local display = require("display")
local native = require("native")
local transition = require("transition")
local composer = require("composer")
local mini_game_view_class = require("classes.mini_game_view_class")
local table = require("table")

local my_games_view_class = {}
local my_games_view_class_mt = { __index = my_games_view_class }

-- Constants
local PAD = 10
local MINI_GAME_WIDTH = display.contentWidth - PAD * 2
local MINI_GAME_HEIGHT = 600
local MINI_BOARD_WIDTH = 350

function my_games_view_class.new(authUser, inProgress, scene)
    local myGamesView = {
        authUser = authUser,
        inProgress = inProgress,
        scene = scene,
        miniGameViews = {}
    }
    return setmetatable(myGamesView, my_games_view_class_mt)
end

function my_games_view_class:setGames(games)
    self.games = games
end

function my_games_view_class:render()
    -- Remove any existing view.
    common_ui.safeRemove(self.view)

    local group = display.newGroup()

    local title = self:renderTitle()

    if self.games and self.games.list and #(self.games.list) > 0 then
        self.tableView = self:renderTableView()
        self:createMiniGames()
        self:insertRows()
        group:insert(self.tableView)
    else
        self.emptyGamesGroup = self:renderEmptyGamesGroup()
        group:insert(self.emptyGamesGroup)
    end

    group:insert(title)

    self.view = group
    return group
end

function my_games_view_class:insertRows(start)
    start = start or 1
    for i = start, #(self.games.list) do
        self.tableView:insertRow {
            rowHeight = MINI_GAME_HEIGHT + PAD,
            isCategory = false,
            rowColor = { default = { 0.3, 0.3, 0.3, 0 }, over = { 0.3, 0.3, 0.3, 0.2 } }
        }
    end
end

function my_games_view_class:destroy()
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

function my_games_view_class:renderTitle()
    local titleText
    if self.inProgress then
        titleText = "Active Games"
    else
        titleText = "Finished Games"
    end
    local title = display.newText {
        text = titleText,
        x = display.contentWidth / 2,
        y = 100,
        width = display.contentWidth,
        align = "center",
        font = fonts.BOLD_FONT,
        fontSize = 52
    }
    title:setFillColor(0, 0, 0)
    return title
end

function my_games_view_class:renderEmptyGamesGroup()
    local group = display.newGroup()
    group.x = display.contentWidth / 2
    group.y = display.contentHeight / 2
    local message
    if self.inProgress then
        message = "No active games."
    else
        message = "No finished games."
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
        composer.gotoScene("scenes.start_multiplayer_scene", "fade")
    end)

    group:insert(messageText)
    group:insert(linkText)
    return group
end

function my_games_view_class:renderTableView()
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

function my_games_view_class:createMiniGames(start)
    local games = self.games
    if not games or not games.list then
        return
    end
    start = start or 1
    for i = start, #(games.list) do
        local miniGameView = mini_game_view_class.new(i, games.list[i], self.authUser, MINI_GAME_WIDTH, MINI_GAME_HEIGHT, MINI_BOARD_WIDTH, 50, 40, self.scene)
        self.miniGameViews[i] = miniGameView
    end
end

function my_games_view_class:createOnRowRenderListener()
    return function(event)
        local games = self.games
        if not games or not games.list then
            return
        end
        local gamesList = games.list

        local row = event.row
        local index = row.index

        if not gamesList[index] then
            print("games[" .. index .. "] is not defined, so not rendering a row.")
            return
        end

        local miniGameView = self.miniGameViews[index]

        miniGameView:render()
        local miniGameViewGroup = miniGameView.view
        miniGameViewGroup.alpha = 0
        miniGameViewGroup.x = PAD

        row:insert(miniGameViewGroup)
        transition.fadeIn(miniGameViewGroup, { time = 1000 })

        -- If the last row is being rendered, then query the server for additional data
        if index == #gamesList and type(games.nextPage) == "number"
                and games.nextPage > 0
                and #gamesList == games.nextPage * common_api.COUNT_PER_PAGE then
            print("Querying for next page of games...page=" .. tostring(games.nextPage))
            local function onSuccess(updatedGames)
                if type(updatedGames) ~= "table" or not updatedGames.list then
                    print("Invalid response when updating games")
                    return
                end
                if type(self.games) ~= "table" or not self.games.list then
                   return
                end
                local startNewGames = #gamesList + 1
                for i = 1, #updatedGames.list do
                   local newIndex = #gamesList + 1
                   gamesList[newIndex] = updatedGames.list[i]
                end

                self:createMiniGames(startNewGames)
                self:insertRows(startNewGames)
                self.games.nextPage = updatedGames.nextPage

            end

            common_api.getMyGames(common_api.COUNT_PER_PAGE,
                games.nextPage,
                self.inProgress,
                self.inProgress,
                onSuccess,
                common_api.showNetworkError,
                common_api.showNetworkError,
                false)

        end
    end
end



return my_games_view_class
