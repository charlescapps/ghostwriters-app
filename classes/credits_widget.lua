local common_ui = require("common.common_ui")
local display = require("display")
local widget = require("widget")
local fonts = require("globals.fonts")
local math = require("math")

local M = {}
local meta = { __index = M }

function M.new()
    local creditsWidget = {}
    return setmetatable(creditsWidget, meta)
end

function M:render()
    self.view = display.newGroup()
    self.bg = self:drawBg()
    self.tableView = self:drawTableView()

    self.view:insert(self.bg)
    self.view:insert(self.tableView)
    return self.view
end

function M:drawBg()
    local img = display.newImageRect("images/credits_bg.jpg", display.contentWidth, display.contentHeight)
    img.x = display.contentCenterX
    img.y = display.contentCenterY
    return img
end

function M:drawTableView()
    local tv = widget.newTableView {
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = display.contentWidth,
        height = display.contentHeight,
        isLocked = true,
        onRowRender = self:getOnRowRender(),
        noLines = true,
        backgroundColor = { 0, 0, 0, 0 },
        hideBackground = true,
        hideScrollBar = true,
    }

    local NUM_ROWS = 1

    for i = 1, NUM_ROWS do
        tv:insertRow {
            rowHeight = display.contentHeight,
            rowColor = {default = {0, 0, 0, 0}, over = {0, 0, 0, 0}}
        }
    end


    return tv
end

function M:getOnRowRender()
    return function(event)
        local row = event.row
        local index = row.index

        local fn = self.renderRows[index]

        if type(fn) ~= "function" then
           return
        end

        local page = fn()
        row:insert(page)

    end
end

function M.drawCreditsPage(opts)
    local group = display.newGroup()
    group.x = display.contentCenterX
    group.y = display.contentCenterY

    local titleView = display.newText {
        text = opts.title,
        font = fonts.BOLD_FONT,
        fontSize = opts.titleSize or 64
    }
    titleView:setFillColor(1, 1, 1)
    titleView.y = -300

    local textView = display.newText {
        text = opts.text,
        font = fonts.DEFAULT_FONT,
        fontSize = opts.textSize or 40
    }
    textView:setFillColor(1, 1, 1)
    textView.y = -200

    if (opts.image and opts.imageWidth and opts.imageHeight) then
        local imageView = display.newImageRect(opts.image, opts.imageWidth, opts.imageHeight)
        imageView.x = 0
        imageView.y = math.max(0, opts.imageHeight / 2 + textView.y + textView.contentHeight / 2) -- Image should not spill into the above text
    end

    group:insert(titleView)
    group:insert(textView)
    return group
end

function M.drawCopyrightPage()
    return M.drawCreditsPage {
        title = "Credits",
        text = "Ghostwriters © 2015 Charles Capps"
    }
end

M.renderRows = {
    M.drawCopyrightPage
}

return M
