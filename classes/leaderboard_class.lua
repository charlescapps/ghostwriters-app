local display = require("display")
local native = require("native")
local widget = require("widget")
local common_api = require("common.common_api")

local leaderboard_class = {}
local leaderboard_class_mt = { __index = leaderboard_class }

function leaderboard_class.new()
    local leaderBoard = {
    }
    return setmetatable(leaderBoard, leaderboard_class_mt)
end

function leaderboard_class:render()
    self.view = display.newGroup()
    self.title = self:renderTitle()

    self.view:insert(self.title)
    return self.view
end

function leaderboard_class:loadRanksNearUser(userId)
    self.userId = userId

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
        x = display.contentWidth / 2,
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
        local users = self.users
        if not users then
            return
        end

        local row = event.row
        local index = row.index

        if not users[index] then
            print("users[" .. index .. "] is not defined, so not rendering a row.")
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


return leaderboard_class

