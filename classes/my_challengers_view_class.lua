local widget = require("widget")
local common_ui = require("common.common_ui")
local common_api = require("common.common_api")
local fonts = require("globals.fonts")
local game_helpers = require("common.game_helpers")
local display = require("display")
local native = require("native")
local transition = require("transition")
local composer = require("composer")
local nav = require("common.nav")
local mini_game_view_class = require("classes.mini_game_view_class")

local my_challengers_view_class = {}
local my_challengers_view_class_mt = { __index = my_challengers_view_class }

-- Constants
local PAD = 10
local MINI_GAME_WIDTH = display.contentWidth - PAD * 2
local MINI_GAME_HEIGHT = 600
local MINI_BOARD_WIDTH = 350

local SPRING_DIST = 80

function my_challengers_view_class.new(authUser, challengedToMe, scene, refreshFunc)
    local myGamesView = {
        authUser = authUser,
        challengedToMe = challengedToMe,
        scene = scene,
        miniGameViews = {},
        refreshFunc = refreshFunc
    }
    return setmetatable(myGamesView, my_challengers_view_class_mt)
end

function my_challengers_view_class:setGames(games)
    self.games = games
end

function my_challengers_view_class:render()
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

function my_challengers_view_class:insertRows(start)
    start = start or 1
    for i = start, #(self.games.list) do
        self.tableView:insertRow {
            rowHeight = MINI_GAME_HEIGHT + PAD,
            isCategory = false,
            rowColor = { default = { 0.3, 0.3, 0.3, 0 }, over = { 0.3, 0.3, 0.3, 0.2 } }
        }
    end
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
        y = 100,
        width = display.contentWidth,
        align = "center",
        font = fonts.BOLD_FONT,
        fontSize = 52
    }
    title:setFillColor(0, 0, 0)
    return title
end

function my_challengers_view_class:renderEmptyGamesGroup()
    local group = display.newGroup()
    group.x = display.contentWidth / 2
    group.y = display.contentHeight / 2
    local message, fontSize
    if self.challengedToMe then
        message = "No challengers yet!"
        fontSize = 60
    else
        message = "You haven't challenged any players!"
        fontSize = 52
    end
    local messageText = display.newText {
        text = message,
        width = 7 * display.contentWidth / 8,
        align = "center",
        font = native.systemFont,
        fontSize = fontSize
    }
    messageText:setFillColor(0, 0, 0)

    local linkText = common_ui.createLink("Start a new game!", 0, 100, 48, function()
        composer.gotoScene("scenes.start_multiplayer_scene", "fade")
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
        hideScrollbar = true,
        listener = self:getTableListener()
    }
end

function my_challengers_view_class:getTableListener()
    return function(event)
        if ( event.phase == "began" ) then
            local table = event.target and event.target.parent and event.target.parent.parent
            if not table or type(table.getContentPosition) ~= "function" then
                return true
            end
            self.springStart = table:getContentPosition()
            self.needToReload = false
        elseif ( event.phase == "moved" ) then
            local table = event.target and event.target.parent and event.target.parent.parent
            if not table or type(table.getContentPosition) ~= "function" then
                return true
            end
            local pos = table:getContentPosition()
            if pos > SPRING_DIST then
                self.needToReload = true
                table:scrollToY({
                    y = SPRING_DIST ,
                    time = 0
                })
            end
        elseif ( event.limitReached == true and event.phase == nil and event.direction == "down" and self.needToReload == true ) then
            print( "Reloading My Games!" )
            self.needToReload = false
            if type(self.refreshFunc) == "function" then
                self.refreshFunc()
            end
        end
        return true
    end
end

function my_challengers_view_class:createMiniGames(start)
    local games = self.games
    if not games or not games.list then
        return
    end
    start = start or 1
    for i = start, #(games.list) do
        local miniGameView = mini_game_view_class.new(i, games.list[i], self.authUser,
            MINI_GAME_WIDTH, MINI_GAME_HEIGHT, MINI_BOARD_WIDTH, 50, 40,
            self.scene, true,
            self:getAcceptGameListener(i), self:getRejectGameListener(i))
        self.miniGameViews[i] = miniGameView
    end
end

function my_challengers_view_class:createOnRowRenderListener()
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
        transition.fadeIn(miniGameViewGroup, { time = 2000 })

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

            common_api.getGamesOfferedToMe(common_api.COUNT_PER_PAGE,
                games.nextPage,
                onSuccess,
                common_api.showNetworkError,
                common_api.showNetworkError,
                false)

        end
    end
end

function my_challengers_view_class:getGameAtIndex(index)
    return self.games and self.games.list and self.games.list[index]
end

function my_challengers_view_class:getOnRejectGameSuccessListener(index)
    return function()
        self.tableView:deleteRows({ index }, { slideLeftTransitionTime = 1000 })
    end
end

function my_challengers_view_class:getAcceptGameListener(index)
    return function()
        local game = self:getGameAtIndex(index)
        if not game then
            print("Error - no game found with index: " .. tostring(index))
            return
        end
        game_helpers.goToAcceptGameScene(game.id,
                                         game.boardSize,
                                         game.specialDict,
                                         game.gameDensity,
                                         game.bonusesType)
    end
end

function my_challengers_view_class:getRejectGameListener(index)
    return function()
        local game = self:getGameAtIndex(index)
        if not game then
            print("Error - no game found with index: " .. tostring(index))
            return
        end
        common_api.rejectGameOffer(game.id, self:getOnRejectGameSuccessListener(index), common_api.showNetworkError, true)
    end
end

return my_challengers_view_class
