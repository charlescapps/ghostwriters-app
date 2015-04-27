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
local TABLE_HEIGHT = 950
local ROW_HEIGHT = 150
local BUTTON_PAD = 6
local BUTTON_SIZE = 180

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
    self.top100Button = self:createTop100Button()
    self.monkeyButton = self:createMonkeyButton()
    self.bookwormButton = self:createBookwormButton()
    self.professorButton = self:createProfessorButton()

    self.view:insert(self.title)
    self.view:insert(self.tableView)
    self.view:insert(self.top100Button)
    self.view:insert(self.monkeyButton)
    self.view:insert(self.bookwormButton)
    self.view:insert(self.professorButton)
    return self.view
end

function leaderboard_class:clear()
    self.users = {}
    self.leaderboardRows = {}
end

function leaderboard_class:loadRanksNearUser(userId)
    print("Loading ranks near user id:" .. tostring(userId))
    self.userId = userId
    self.username = nil
    self.highlightIndex = nil
    common_api.getUsersWithSimilarRank(self.userId, 10, self:getOnLoadRanksSuccessListener(), self:getOnLoadRanksFailListener(), true)
end

function leaderboard_class:loadTop100()
    print("Loading top 100 ranks...")
    self.userId = nil
    self.username = nil
    self.highlightIndex = 1
    common_api.getBestRankedUsers(100, self:getOnLoadRanksSuccessListener(), self:getOnLoadRanksFailListener(), true)
end

function leaderboard_class:loadRanksNearMonkey()
    print("Loading ranks near Monkey...")
    self.userId = nil
    self.username = common_api.MONKEY_USERNAME
    self.highlightIndex = nil
    common_api.getRanksNearMonkey(10, self:getOnLoadRanksSuccessListener(), self:getOnLoadRanksFailListener(), true)
end

function leaderboard_class:loadRanksNearBookworm()
    print("Loading ranks near Bookworm...")
    self.userId = nil
    self.username = common_api.BOOKWORM_USERNAME
    self.highlightIndex = nil
    common_api.getRanksNearBookworm(10, self:getOnLoadRanksSuccessListener(), self:getOnLoadRanksFailListener(), true)
end

function leaderboard_class:loadRanksNearProfessor()
    print("Loading ranks near Bookworm...")
    self.userId = nil
    self.username = common_api.PROFESSOR_USERNAME
    self.highlightIndex = nil
    common_api.getRanksNearProfessor(10, self:getOnLoadRanksSuccessListener(), self:getOnLoadRanksFailListener(), true)
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
            if self.userId and self.userId == user.id or
                    self.username and self.username == user.username or
                    self.highlightIndex and self.highlightIndex == i then
                focusedUserIndex = i
            end
            self.leaderboardRows[i] = leaderboard_row.new(i, user, TABLE_WIDTH, ROW_HEIGHT, self.parentScene, self.authUser,
                focusedUserIndex == i)

            self.tableView:insertRow {
                rowHeight = ROW_HEIGHT,
                rowColor = { default = { 1, 1, 1, 0 }, over = { 1, 1, 1, 0.4 } },
                params = { leaderboardRow = self.leaderboardRows[i] }
            }
        end

        if focusedUserIndex and focusedUserIndex > 3 then
            self.tableView:scrollToIndex(focusedUserIndex + 3, 1000)
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
        y = 75,
        width = display.contentWidth,
        align = "center",
        font = native.systemFontBold,
        fontSize = 60
    }
    title:setFillColor(0, 0, 0)
    return title
end

function leaderboard_class:renderTableView()
    return widget.newTableView {
        x = TABLE_WIDTH / 2,
        y = 825,
        width = TABLE_WIDTH,
        height = TABLE_HEIGHT,
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


        row:insert(rowView)
        rowView.alpha = 0

        transition.fadeIn(rowView, { time = 2000 })

    end
end

function leaderboard_class:createTop100Button()
    return widget.newButton {
        x = BUTTON_PAD + BUTTON_SIZE / 2,
        y = BUTTON_SIZE / 2 + 150,
        width = BUTTON_SIZE,
        height = BUTTON_SIZE,
        defaultFile = "images/top_100_default.png",
        overFile = "images/top_100_over.png",
        onRelease = function() self:loadTop100() end
    }
end

function leaderboard_class:createMonkeyButton()
    return widget.newButton {
        x = BUTTON_PAD * 2 + 3 * BUTTON_SIZE / 2,
        y = BUTTON_SIZE / 2 + 150,
        width = BUTTON_SIZE,
        height = BUTTON_SIZE,
        defaultFile = "images/monkey_default.png",
        overFile = "images/monkey_over.png",
        onRelease = function() self:loadRanksNearMonkey() end
        }
end

function leaderboard_class:createBookwormButton()
    return widget.newButton {
        x = BUTTON_PAD * 3 + 5 * BUTTON_SIZE / 2,
        y = BUTTON_SIZE / 2 + 150,
        width = BUTTON_SIZE,
        height = BUTTON_SIZE,
        defaultFile = "images/bookworm_default.png",
        overFile = "images/bookworm_over.png",
        onRelease = function() self:loadRanksNearBookworm() end
        }
end

function leaderboard_class:createProfessorButton()
    return widget.newButton {
        x = BUTTON_PAD * 4 + 7 * BUTTON_SIZE / 2,
        y = BUTTON_SIZE / 2 + 150,
        width = BUTTON_SIZE,
        height = BUTTON_SIZE,
        defaultFile = "images/professor_default.png",
        overFile = "images/professor_over.png",
        onRelease = function() self:loadRanksNearProfessor() end
    }
end


return leaderboard_class

