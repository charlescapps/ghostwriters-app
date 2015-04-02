local display = require("display")
local native = require("native")
local widget = require("widget")
local transition = require("transition")
local json = require("json")
local math = require("math")

local common_api = require("common.common_api")

local user_search_widget = {}
local user_search_widget_mt = { __index = user_search_widget }

-- Constants
local BOX_TOP_MARGIN = 100
local BOX_SIDE_MARGIN = 90
local ROW_HEIGHT = 80
local EVEN_ROW_COLOR = { default = { 0.46, 0.78, 1.0, 0.2 }, over = { 0.46, 0.78, 1.0, 0.6 } }
local ODD_ROW_COLOR = { default = { 0.87, 0.95, 1.0, 0.2 }, over = { 0.87, 0.95, 1.0, 0.6 } }

function user_search_widget.new(authUser, x, y, boxWidth, boxHeight)

    local numVisibleRows = math.ceil((boxHeight - 2 * BOX_TOP_MARGIN) / ROW_HEIGHT)

    local userSearchWidget = {
        authUser = authUser,
        x = x,
        y = y,
        boxWidth = boxWidth,
        boxHeight = boxHeight,
        numVisibleRows = numVisibleRows
    }

    return setmetatable(userSearchWidget, user_search_widget_mt)
end

function user_search_widget:render()
    self:destroy()
    self.view = display.newGroup()
    self.view.x, self.view.y = self.x, self.y

    self.background = self:createBackground()
    self.tableView = self:createTableView()

    self.view:insert(self.background)
    self.view:insert(self.tableView)
    return self.view
end

function user_search_widget:destroy()
    if self.view then
        self.view:removeSelf()
    end
    self.view = nil
    self.background = nil
    self.tableView = nil
    self.authUserIndex = nil
end

function user_search_widget:createBackground()
    local bg = display.newImageRect("images/user_search_widget_bg.png", self.boxWidth, self.boxHeight)
    bg.x, bg.y = self.boxWidth / 2, self.boxHeight / 2
    return bg
end

function user_search_widget:createTableView()
    local tableView = widget.newTableView {
        x = self.boxWidth / 2,
        y = self.boxHeight / 2,
        width = self.boxWidth - 2 * BOX_SIDE_MARGIN,
        height = self.boxHeight - 2 * BOX_TOP_MARGIN,
        hideBackground = true,
        noLines = true,
        onRowRender = self:getOnRowRenderListener(),
        onRowTouch = self:getOnRowTouchListener()
    }
    return tableView
end

function user_search_widget:getOnRowRenderListener()
    return function(event)
        local row = event.row
        local rowWidth, rowHeight = row.contentWidth, row.contentHeight
        local index = row.index

        if #(self.users) < index then
            print("Error - rendering row index " .. index .. ", but num users is: " .. #(self.users))
            return
        end

        local user = self.users[index]
        local rowText = user.username .. " (" .. math.floor(user.rating / 1000) .. ")"
        local font = index == self.authUserIndex and native.systemFontBold or native.systemFont
        local rowTitle = display.newText(row, rowText, rowWidth / 2, rowHeight / 2, font, 32)
        rowTitle:setFillColor(0, 0, 0)

        row.alpha = 0
        transition.fadeIn(row, { time = 1000 })
    end
end

function user_search_widget:getOnRowTouchListener()
    return function(event)
    end
end

function user_search_widget:getOnQuerySuccessListener()
    return function(jsonResult)
        if not jsonResult or not jsonResult.list then
            print("Error - invalid user list result back from server: " .. json.encode(jsonResult))
            self.users = {}
            return
        end

        self.users = jsonResult.list
        self.tableView:deleteAllRows()

        for i = 1, #(self.users) do
            local rowColor = i % 2 == 1 and ODD_ROW_COLOR or EVEN_ROW_COLOR

            print("Row: " .. i .. ", user ID= " .. tostring(self.users[i].id) .. ", authUserId = " .. tostring(self.authUser.id))

            if self.users and self.users[i] and self.users[i].id == self.authUser.id then
                self.authUserIndex = i
                print("Found authUserIndex = " .. i)
            end

            self.tableView:insertRow {
                isCategory = false,
                rowHeight = ROW_HEIGHT,
                rowColor = rowColor
            }
        end

        for i = #(self.users) + 1, self.numVisibleRows do
            local rowColor = i % 2 == 1 and ODD_ROW_COLOR or EVEN_ROW_COLOR
            self.tableView:insertRow {
                isCategory = false,
                rowHeight = ROW_HEIGHT,
                rowColor = rowColor
            }
        end

        if self.authUserIndex then
            self.tableView:scrollToIndex(self.authUserIndex)
        end
    end
end

function user_search_widget:getOnQueryFailListener()
    return function()
        native.showAlert("Network error", "A network error occurred, please tap the magnifying glass to search for opponents again.", { "Try again" })
    end
end

function user_search_widget:queryForUsers()
    common_api.getUsersWithSimilarRating(20, self:getOnQuerySuccessListener(), self:getOnQueryFailListener())
end


return user_search_widget
