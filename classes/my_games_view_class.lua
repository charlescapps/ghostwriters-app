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
    print("my_games_view_class:setting games to array of size: " .. #(games.list))
    self.games = games
end

function my_games_view_class:render()
    print("Rendering table view...")
    self.tableView = self:renderTableView()
    for i = 1, #(self.games.list) do
        print("Inserting row: " .. i)
        self.tableView:insertRow {
            rowHeight = 600,
            isCategory = false,
            rowColor = { default={ 0.3, 0.3, 0.3, 0 }, over={ 0.3, 0.3, 0.3, 0.2 } }
        }
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
        if not games or not games.list then
            return
        end

        local row = event.row
        local index = row.index

        if not games.list[index] then
            print("games[" .. index .. "] is not defined, so not rendering a row.")
            return
        end

        local miniGameView = mini_game_view_class.new(
            games.list[index], self.authUser, MINI_GAME_WIDTH, MINI_BOARD_WIDTH, 50, 40)

        self.miniGameViews[index] = miniGameView
        local miniGameViewGroup = miniGameView:render()

        row:insert(miniGameViewGroup)
    end
end



return my_games_view_class
