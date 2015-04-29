local display = require("display")
local native = require("native")
local game_helpers = require("common.game_helpers")
local user_info_popup = require("classes.user_info_popup")

local leaderboard_row = {}
local leaderboard_row_mt = { __index = leaderboard_row }

local BOOKMARK_WIDTH = 750
local BOOKMARK_HEIGHT = 150

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
    self.rankText = self:createRankText()
    self.usernameText = self:createUsernameText(self.rankText)
    self.ratingText = self:createRatingText(self.usernameText)

    self.view:insert(self.bookmarkBg)
    self.view:insert(self.rankText)
    self.view:insert(self.usernameText)
    self.view:insert(self.ratingText)

    return self.view
end

function leaderboard_row:createBookmarkBg()
    local imgFile = self.index % 2 == 0 and "images/brown_bookmark.png" or "images/red_bookmark.png"
    local bookmarkImg = display.newImageRect(imgFile, BOOKMARK_WIDTH, BOOKMARK_HEIGHT)
    bookmarkImg.x = BOOKMARK_WIDTH / 2
    bookmarkImg.y = self.rowHeight / 2
    return bookmarkImg
end

function leaderboard_row:createRankText()
    local rankNumberText = display.newText {
        text = "#" .. tostring(self.user.rank),
        font = native.systemFontBold,
        fontSize = 40
    }

    rankNumberText.anchorX = 0
    rankNumberText.x = 20
    rankNumberText.y = self.rowHeight / 2
    rankNumberText:setFillColor(0, 0, 0)

    return rankNumberText
end

function leaderboard_row:createUsernameText(rankText)
    local usernameText = display.newText {
        text = self.user.username,
        font = self.isHighlighted and native.systemFontBold or native.systemFont,
        fontSize = self.isHighlighted and 36 or 32
    }

    usernameText.anchorX = 0
    usernameText.x = rankText.x + rankText.contentWidth + 20
    usernameText.y = self.rowHeight / 2
    usernameText:setFillColor(0, 0, 0)

    local that = self
    function usernameText:touch(event)
        if event.phase == "ended" then
            that.parentScene.userInfoPopup = user_info_popup.new(that.user, that.parentScene, that.authUser, true)
            that.parentScene.view:insert(that.parentScene.userInfoPopup:render())
        end
        return true
    end

    usernameText:addEventListener("touch")

    return usernameText
end

function leaderboard_row:createRatingText(usernameText)
    local ratingText = display.newText {
        text = "( " .. tostring(game_helpers.getFriendlyRating(self.user.rating)) .. " )",
        font = native.systemFont,
        fontSize = 30
    }

    ratingText.anchorX = 0
    ratingText.x = usernameText.x + usernameText.contentWidth + 40
    ratingText.y = self.rowHeight / 2
    ratingText:setFillColor(0, 0, 0)

    return ratingText
end

return leaderboard_row
