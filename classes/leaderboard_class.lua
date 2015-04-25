local display = require("display")
local native = require("native")
local widget = require("widget")
local transition = require("transition")
local json = require("json")
local leaderboard_row = require("classes.leaderboard_row")
local common_api = require("common.common_api")

local leaderboard_class = {}
local leaderboard_class_mt = { __index = leaderboard_class }

local TABLE_WIDTH = 750
local ROW_HEIGHT = 150

function leaderboard_class.new(parentScene, authUser)
    local leaderBoard = {
        users = {},
        leaderboardRows = {},
        parentScene = parentScene,
        authUser = authUser
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
    print("Loading ranks near user id:" .. tostring(userId))
    self.userId = userId
    common_api.getUsersWithSimilarRank(self.userId, 10, self:getOnLoadRanksSuccessListener(), self:getOnLoadRanksFailListener(), true)
end

function leaderboard_class:getOnLoadRanksSuccessListener()
    return function(jsonResp)
        if not jsonResp or not jsonResp.list then
            print("Error - invalid users list returned from server:" .. json.encode(jsonResp))
            return
        end

        -- Remove old rows, and clear any data.
        self.tableView:deleteAllRows()
        self:clear()

        self.users = jsonResp.list

        local focusedUserIndex

        print("Adding rows...")
        for i = 1, #self.users do
            print("Inserting row #" .. i)
            local user = self.users[i]
            if user.id == self.userId then
                focusedUserIndex = i
            end
            self.leaderboardRows[i] = leaderboard_row.new(i, user, TABLE_WIDTH, ROW_HEIGHT, self.parentScene, self.authUser, user.id == self.userId)

            self.tableView:insertRow {
                rowHeight = ROW_HEIGHT,
                rowColor = { default = { 1, 1, 1, 0 }, over = { 1, 1, 1, 0.4 } },
                params = { leaderboardRow = self.leaderboardRows[i] }
            }
        end

        if focusedUserIndex and focusedUserIndex > 3 then
            self.tableView:scrollToIndex(focusedUserIndex, 1000)
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
        y = 800,
        width = TABLE_WIDTH,
        height = 1000,
        onRowRender = self:createOnRowRenderListener(),
        backgroundColor = { 1, 1, 1, 0 },
        hideBackground = true,
        hideScrollbar = true
    }
end

function leaderboard_class:createOnRowRenderListener()
    return function(event)
        local row = event.row
        local leaderboardRow = row and row.params and row.params.leaderboardRow

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

