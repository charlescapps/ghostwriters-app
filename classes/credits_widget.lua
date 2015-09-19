local common_ui = require("common.common_ui")
local display = require("display")
local widget = require("widget")
local fonts = require("globals.fonts")
local math = require("math")
local timer = require("timer")

local M = {}
local meta = { __index = M }

function M.new()
    local creditsWidget = {
        currentRow = 1
    }
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

    for i = 1, #M.renderRows do
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

function M:animateCredits()
    if not self.tableView then
        return
    end

    if type(self.currentRow) ~= "number" then
        return
    end

    if self.currentRow >= #M.renderRows then
        return
    end

    local function onComplete()
        self.currentRow = self.currentRow + 1

        self:animateCredits()
    end

    timer.performWithDelay(3000, function()
        self.tableView:scrollToIndex(self.currentRow + 1, 2000, onComplete)
    end)
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
    titleView.y = -350

    local textView = display.newText {
        text = opts.text,
        font = fonts.DEFAULT_FONT,
        fontSize = opts.textSize or 52
    }
    textView:setFillColor(1, 1, 1)
    textView.y = -250

    group:insert(titleView)
    group:insert(textView)

    local subtitleView
    if opts.subtitle then
        subtitleView = display.newText {
            text = opts.subtitle,
            font = fonts.DEFAULT_FONT,
            fontSize = opts.subtitleSize or 48
        }
        subtitleView.anchorY = 0
        subtitleView:setFillColor(1, 1, 1)
        subtitleView.y = textView.y + textView.contentHeight / 2 + 10
        group:insert(subtitleView)
    end

    if (opts.image and opts.imageWidth and opts.imageHeight) then
        local IMAGE_PAD = 75
        local imageView = display.newImageRect(opts.image, opts.imageWidth, opts.imageHeight)
        imageView.x = 0
        local prevView = subtitleView or textView
        imageView.y = opts.imageHeight / 2 + prevView.y + prevView.contentHeight / 2 + IMAGE_PAD -- Image should not spill into the above text
        group:insert(imageView)
    end

    return group
end

function M.drawCopyrightPage()
    return M.drawCreditsPage {
        title = "Credits",
        text = "Ghostwriters © 2015 Charles Capps",
        image = "images/cthulhu_board.jpg",
        imageWidth = 600,
        imageHeight = 600,
        textSize = 40
    }
end

function M.drawArtistPage()
    return M.drawCreditsPage {
        title = "Original Artwork",
        text = "Joao Fiuza",
        subtitle = "https://inkognit.artstation.com",
        image = "images/professor_default.png",
        imageWidth = 600,
        imageHeight = 600
    }
end

M.renderRows = {
    M.drawCopyrightPage,
    M.drawArtistPage
}

return M
