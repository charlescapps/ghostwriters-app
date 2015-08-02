local display = require("display")
local native = require("native")
local fonts = require("globals.fonts")
local user_info_popup = require("classes.user_info_popup")
local format_helpers = require("common.format_helpers")
local common_api = require("common.common_api")

local leaderboard_row = {}
local leaderboard_row_mt = { __index = leaderboard_row }

local BOOKMARK_WIDTH = 750
local BOOKMARK_HEIGHT = 125
local HIGHLIGHT_COLOR = {0.93, 0.48, 0.01}

function leaderboard_row.new(index, user, rowWidth, rowHeight, parentScene, authUser, isHighlighted)
    local leaderboardRow = {
        index = index,
        user = user,
        rowWidth = rowWidth,
        rowHeight = rowHeight,
        parentScene = parentScene,
        authUser = authUser,
        isHighlighted = isHighlighted
    }

    return setmetatable(leaderboardRow, leaderboard_row_mt)
end

function leaderboard_row:render()
    self.view = display.newGroup()
    self.bookmarkBg = self:createBookmarkBg()
    self.view:insert(self.bookmarkBg)

    if self.user then
        self.rankText = self:createRankText()
        self.usernameText = self:createUsernameText(self.rankText)
        self.ratingText = self:createRatingText(self.usernameText)

        self.view:insert(self.rankText)
        self.view:insert(self.usernameText)
        self.view:insert(self.ratingText)
    end

    return self.view
end

function leaderboard_row:createBookmarkBg()
    local imgFile = self.index % 2 == 0 and "images/bookmark1.png" or "images/bookmark2.png"
    local bookmarkImg = display.newImageRect(imgFile, BOOKMARK_WIDTH, BOOKMARK_HEIGHT)
    bookmarkImg.x = BOOKMARK_WIDTH / 2
    bookmarkImg.y = self.rowHeight / 2

    bookmarkImg:addEventListener("touch", self:getOnTouchListener())
    bookmarkImg:addEventListener("tap", function() return true end)

    return bookmarkImg
end

function leaderboard_row:createRankText()
    local rankNumberText = display.newText {
        text = "#" .. format_helpers.comma_value(self.user.rank),
        font = fonts.BOLD_FONT,
        fontSize = 40
    }

    rankNumberText.anchorX = 0
    rankNumberText.x = 20
    rankNumberText.y = self.rowHeight / 2
    if self.isHighlighted then
        rankNumberText:setFillColor(HIGHLIGHT_COLOR[1], HIGHLIGHT_COLOR[2], HIGHLIGHT_COLOR[3])
    else
        rankNumberText:setFillColor(1, 1, 1)
    end

    return rankNumberText
end

function leaderboard_row:createUsernameText(rankText)
    local username = self.user.username
    if username == common_api.MONKEY_USERNAME then
       username = common_api.MONKEY_USERNAME .. " (AI)"
    elseif username == common_api.PROFESSOR_USERNAME then
        username = common_api.PROFESSOR_USERNAME .. " (AI)"
    elseif username == common_api.BOOKWORM_USERNAME then
        username = common_api.BOOKWORM_USERNAME .. " (AI)"
    end
    local usernameText = display.newText {
        text = username,
        font = self.isHighlighted and fonts.BOLD_FONT or native.systemFont,
        fontSize = self.isHighlighted and 36 or 32
    }

    usernameText.anchorX = 0
    usernameText.x = rankText.x + rankText.contentWidth + 20
    usernameText.y = self.rowHeight / 2
    if self.isHighlighted then
        usernameText:setFillColor(HIGHLIGHT_COLOR[1], HIGHLIGHT_COLOR[2], HIGHLIGHT_COLOR[3])
    else
        usernameText:setFillColor(1, 1, 1)
    end

    return usernameText
end

function leaderboard_row:getOnTouchListener()
    return function(event)
        if event.x > self.usernameText.x + self.usernameText.contentWidth then
            return false
        end
        if event.phase == "ended" then
            if not self.parentScene or not self.parentScene.view or not self.parentScene.view.removeSelf then
                return true
            end
            self.parentScene.userInfoPopup = user_info_popup.new(self.user, self.parentScene, self.authUser, true)
            self.parentScene.view:insert(self.parentScene.userInfoPopup:render())
        end
        return true
    end
end

function leaderboard_row:createRatingText()
    local ratingText = display.newText {
        text = format_helpers.comma_value(self.user.rating),
        font = native.systemFont,
        fontSize = 30
    }

    ratingText.anchorX = 1
    ratingText.x = self.rowWidth - 150
    ratingText.y = self.rowHeight / 2
    ratingText:setFillColor(1, 1, 1)

    return ratingText
end

return leaderboard_row

