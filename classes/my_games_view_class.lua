local widget = require("widget")
local display = require("display")
local mini_game_view_class = require("classes.mini_game_view_class")

local my_games_view_class = {}
local my_games_view_class_mt = { __index = my_games_view_class }

-- Constants
local MINI_GAME_WIDTH = display.contentWidth - 20
local MINI_BOARD_WIDTH = 400

function my_games_view_class.new(authUser)
    local myGamesView = {
        authUser = authUser,
        miniGameViews = {}
    }
    return setmetatable(myGamesView, my_games_view_class_mt)
end

function my_games_view_class:setGames(games)
    self.games = games
end

function my_games_view_class:render()
    self.tableView = self:renderTableView()
    for i = 1, #(self.games) do
        self.tableView:insertRow { }
    end
    return self.tableView
end

function my_games_view_class:destroy()
    if self.tableView then
        self.tableView:removeSelf()
        self.tableView = nil
        self.games = nil
    end
end

function my_games_view_class:renderTableView()
    return widget.newTableView {
        x = display.contentWidth / 2,
        y = display.contentHeight / 2,
        width = display.contentWidth,
        height = display.contentHeight,
        onRowRender = self:createOnRowRenderCallback(),
        backgroundColor = {1, 1, 1, 0},
        hideBackground = true,
        hideScrollbar = true
    }
end

function my_games_view_class:createOnRowRenderCallback()
    return function(event)
        local games = self.games
        if not games then
            return
        end

        local row = event.row
        local index = row.index

        if not games[index] then
            print("games[" .. index .. "] is not defined, so not rendering a row.")
            return
        end

        local miniGameView = mini_game_view_class.new(
            games[index], self.authUser, MINI_GAME_WIDTH, MINI_BOARD_WIDTH, 50, 40)

        self.miniGameViews[index] = miniGameView

        row:insert(miniGameView)
    end
end



return my_games_view_class
