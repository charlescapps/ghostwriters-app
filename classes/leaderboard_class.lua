local display = require("display")
local native = require("native")
local widget = require("widget")
local transition = require("transition")
local json = require("json")
local leaderboard_row = require("classes.leaderboard_row")
local common_api = require("common.common_api")

local leaderboard_class = {}
local leaderboard_class_mt = { __index = leaderboard_class }

local TABLE_WIDTH = 550
local ROW_HEIGHT = 120

function leaderboard_class.new()
    local leaderBoard = {
        users = {},
        leaderboardRows = {}
    }
    return setmetatable(leaderBoard, leaderboard_class_mt)
end

function leaderboard_class:render()
    self.view = display.newGroup()
    self.title = self:renderTitle()
    self.tableView = self:renderTableView()

    self.view:insert(self.title)
    self.view:insert(self.tableView)
    return self.view
end

function leaderboard_class:clear()
    self.users = {}
    self.leaderboardRows = {}
end

function leaderboard_class:loadRanksNearUser(userId)
    self.userId = userId
    common_api.getUsersWithSimilarRank(self.userId, 10, self:getOnLoadRanksSuccessListener(), self:getOnLoadRanksFailListener(), true)
end

function leaderboard_class:getOnLoadRanksSuccessListener()
    return function(jsonResp)
        if not jsonResp or not jsonResp.list then
            print("Error - invalid users list returned from server:" .. json.encode(jsonResp))
            return
        end
        self.users = jsonResp.list

        -- Remove old rows, and clear any data.
        self.tableView:deleteAllRows()
        self:clear()

        for i = 1, #self.users do
            self.leaderboardRows[i] = leaderboard_row.new(i, self.users[i])

            self.tableView:insertRow {
                rowHeight = ROW_HEIGHT,
                rowColor = { default = { 1, 1, 1, 0 }, over = { 1, 1, 1, 0.4 } },
                params = { leaderboardRow = self.leaderboardRows[i] }
            }
        end
    end
end

function leaderboard_class:getOnLoadRanksFailListener()
    return common_api.showNetworkError
end

function leaderboard_class:renderTitle()
    local title = display.newText {
        text = "Leaderboard",
        x = display.contentWidth / 2,
        y = 80,
        width = display.contentWidth,
        align = "center",
        font = native.systemFontBold,
        fontSize = 40
    }
    title:setFillColor(0, 0, 0)
    return title
end

function leaderboard_class:renderTableView()
    return widget.newTableView {
        x = TABLE_WIDTH / 2,
        y = display.contentHeight / 2 + 100,
        width = display.contentWidth - 200,
        height = display.contentHeight - 300,
        onRowRender = self:createOnRowRenderListener(),
        backgroundColor = { 1, 1, 1, 0 },
        hideBackground = true,
        hideScrollbar = true
    }
end

function leaderboard_class:createOnRowRenderlistener()
    return function(event)
        local row = event.row
        local leaderboardRow = event.target and event.target.params and event.target.params.leaderboardRow

        if not leaderboardRow then
            print("Leaderboard Row instance is not defined, so not rendering a row.")
            return
        end

        local rowView = leaderboardRow:render()

        rowView.alpha = 0

        row:insert(rowView)
        transition.fadeIn(rowView, { time = 2000 })

    end
end


return leaderboard_class

