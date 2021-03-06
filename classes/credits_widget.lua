local common_ui = require("common.common_ui")
local display = require("display")
local widget = require("widget")
local fonts = require("globals.fonts")
local timer = require("timer")
local system = require("system")

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

    self.timerId = timer.performWithDelay(3000, function()
        if not common_ui.isValidDisplayObj(self.view) or
                not common_ui.isValidDisplayObj(self.tableView) or
                not common_ui.isValidDisplayObj(self.tableView.parent) or
                not self.tableView.scrollToIndex then
            return
        end
        self.tableView:scrollToIndex(self.currentRow + 1, 2000, onComplete)
    end)
end

function M:cancelActiveTimer()
    if self.timerId then
       timer.cancel(self.timerId)
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
    titleView.y = -350

    local textView = display.newText {
        text = opts.text,
        font = fonts.DEFAULT_FONT,
        fontSize = opts.textSize or 52,
        width = 700,
        x = 0,
        align = "center"
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
            fontSize = opts.subtitleSize or 40,
            width = 700,
            x = 0,
            align = "center"
        }
        subtitleView.anchorY = 0
        subtitleView:setFillColor(1, 1, 1)
        subtitleView.y = textView.y + textView.contentHeight / 2 + 10

        if opts.subtitleIsLink then
            subtitleView:setFillColor(0.93, 0.48, 0.01)
            subtitleView:addEventListener("touch", function(event)
                if event.phase == "ended" then
                    system.openURL(opts.subtitle)
                end
            end)
        end

        group:insert(subtitleView)
    end

    if (opts.image and opts.imageWidth and opts.imageHeight) then
        local IMAGE_PAD = opts.imagePad or 75
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
        text = "Joao Fiuza / Inkognit",
        subtitle = "https://inkognit.carbonmade.com/",
        subtitleIsLink = true,
        image = "images/inkognit.png",
        imageWidth = 500,
        imageHeight = 500
    }
end

function M.drawMusicPage()
    return M.drawCreditsPage {
        title = "Original Music",
        text = "Simon Bielman",
        subtitle = "https://soundcloud.com/simonlb-1",
        subtitleIsLink = true,
        image = "images/simon.jpg",
        imageWidth = 600,
        imageHeight = 600
    }
end

function M.drawFreeSoundPage()
    return M.drawCreditsPage {
        title = "Sound Effects",
        text = "www.freesound.org",
        image = "images/freesound.png",
        imageWidth = 400,
        imageHeight = 104,
        imagePad = 25
    }
end

function M.drawBostonLawPage()
    return M.drawCreditsPage {
        title = "Images of Rare Books",
        text = "Used with permission from",
        subtitle = "Boston College Law Library, Daniel R. Coquillette Rare Book Room",
        image = "images/game_menu_book.jpg",
        imageWidth = 600,
        imageHeight = 712
    }
end

function M.drawLostAndTakenPage()
    return M.drawCreditsPage {
        title = "Vintage Book Textures",
        text = "Lost and Taken",
        subtitle = "http://lostandtaken.com/",
        subtitleIsLink = true,
        image = "images/red_minigame_bg.jpg",
        imageWidth = 600,
        imageHeight = 700
    }
end

function M.drawFinalPage()
    return M.drawCreditsPage {
        title = "Thanks for playing!",
        text = "Check out the forums at",
        subtitle = "http://ghostwritersapp.com/forums",
        subtitleIsLink = true,
        image = "images/rating_up_modal.png",
        imageWidth = 600,
        imageHeight = 600
    }
end

M.renderRows = {
    M.drawCopyrightPage,
    M.drawArtistPage,
    M.drawMusicPage,
    M.drawBostonLawPage,
    M.drawLostAndTakenPage,
    M.drawFreeSoundPage,
    M.drawFinalPage
}

return M
