local display = require("display")
local native = require("native")
local widget = require("widget")
local transition = require("transition")
local json = require("json")
local math = require("math")

local common_api = require("common.common_api")
local common_ui = require("common.common_ui")

local user_search_widget = {}
local user_search_widget_mt = { __index = user_search_widget }

-- Constants
local BOX_TOP_MARGIN = 125
local BOX_SIDE_MARGIN = 90
local ROW_HEIGHT = 80
local EVEN_ROW_COLOR = { default = { 0.46, 0.78, 1.0, 0.2 }, over = { 0.46, 0.78, 1.0, 0.6 } }
local ODD_ROW_COLOR = { default = { 0.87, 0.95, 1.0, 0.2 }, over = { 0.67, 0.75, 0.8, 0.6 } }
local FAKE_ROWS = 1

function user_search_widget.new(authUser, x, y, boxWidth, boxHeight, onRowTouch)

    local numVisibleRows = math.ceil((boxHeight - 2 * BOX_TOP_MARGIN) / ROW_HEIGHT)

    local userSearchWidget = {
        authUser = authUser,
        x = x,
        y = y,
        boxWidth = boxWidth,
        boxHeight = boxHeight,
        onRowTouch = onRowTouch,
        numVisibleRows = numVisibleRows
    }

    return setmetatable(userSearchWidget, user_search_widget_mt)
end

function user_search_widget:render()
    self.view = display.newGroup()
    self.view.x, self.view.y = self.x, self.y

    self.background = self:createBackground()
    self.tableView = self:createTableView()
    self.noResultsText = self:createNoResultsText()
    self.searchAreaGroup = self:createSearchAreaGroup()

    self.view:insert(self.background)
    self.view:insert(self.tableView)
    self.view:insert(self.noResultsText)
    self.view:insert(self.searchAreaGroup)
    return self.view
end

function user_search_widget:destroy()
    if self.view then
        self.view:removeSelf()
    end
    if self.searchAreaGroup then
        self.searchAreaGroup:removeNativeInput()
    end
    self.view = nil
    self.background = nil
    self.tableView = nil
    self.noResultsText = nil
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

function user_search_widget:createSearchAreaGroup()
    local group = display.newGroup()
    group.y = self.boxHeight + 75

    group.searchInput = native.newTextField( 275, 0, 500, 75 )
    group.searchInput.placeholder = "Search for players"
    group.searchInput.size = 16
    group.searchInput.isFontSizeScaled = true

    local onReleaseSearchButton = function()
        local txt = group.searchInput.text
        if txt and txt:len() < 1 then
            self:queryForUsersWithSimilarRating()
        elseif txt and txt:len() >= 1 then
            self:queryForUsersByName(txt)
        end
    end

    group.searchInput:addEventListener("userInput", function(event)
        if event.phase == "ended" or event.phase == "submitted" then
            onReleaseSearchButton()
        end
    end)

    group.searchButton = common_ui.createImageButton(0, 150, 150, "images/search_button_default.png", "images/search_button_over.png", onReleaseSearchButton)
    group.searchButton.x = self.boxWidth - 75

    group:insert(group.searchInput)
    group:insert(group.searchButton)

    function group:removeNativeInput()
        if self.searchInput and self.searchInput.removeSelf then
            self.searchInput:removeSelf()
        end
    end

    return group
end

function user_search_widget:createNoResultsText()
    local noResultsText = display.newText {
        x = self.boxWidth / 2,
        y = self.boxHeight / 2,
        width = self.boxWidth,
        height = 200,
        font = native.systemFontBold,
        fontSize = 36,
        text = "Oops...no results!",
        align = "center"
    }
    noResultsText:setFillColor(0, 0, 0)
    noResultsText.alpha = 0
    return noResultsText
end

function user_search_widget:showNoResultsText()
    if self.noResultsText then
        transition.fadeIn(self.noResultsText, { time = 1500 })
    end
end

function user_search_widget:hideNoResultsText()
    if self.noResultsText then
        transition.fadeOut(self.noResultsText, { time = 1000 })
    end
end

function user_search_widget:getOnRowRenderListener()
    return function(event)
        local row = event.row
        local rowWidth, rowHeight = row.contentWidth, row.contentHeight
        local index = row.index

        if #(self.users) < index then
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
        if event.phase == "release" or event.phase == "tap" then
            local row = event.row
            local index = row.index
            local user = self.users[index]
            if user then
                self.onRowTouch(user)
            end
        end
        return true
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
        self.authUserIndex = nil

        if #(self.users) <= 0 then
            self:showNoResultsText()
            return
        end

        self:hideNoResultsText()

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
            print("Scrolling to authUser at index = " .. self.authUserIndex)
            self.tableView:scrollToIndex(self.authUserIndex)
        else
            print("Scrolling to index = 1")
            self.tableView:scrollToIndex(1)
        end
    end
end

function user_search_widget:getOnQueryFailListener()
    return function()
        native.showAlert("Network error", "A network error occurred, please tap the magnifying glass to search for opponents again.", { "Try again" })
    end
end

function user_search_widget:queryForUsersWithSimilarRating()
    common_api.getUsersWithSimilarRating(20, self:getOnQuerySuccessListener(), self:getOnQueryFailListener())
end

function user_search_widget:queryForUsersByName(q)
    common_api.searchForUsers(q, 40, self:getOnQuerySuccessListener(), self:getOnQueryFailListener(), self:getOnQueryFailListener() )
end


return user_search_widget
