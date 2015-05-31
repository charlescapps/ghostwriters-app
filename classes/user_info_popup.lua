local json = require("json")
local display = require("display")
local native = require("native")
local transition = require("transition")
local os = require("os")
local math = require("math")

local common_ui = require("common.common_ui")
local fonts = require("globals.fonts")

local user_info_popup = {}
local user_info_popup_mt = { __index = user_info_popup }

local POPUP_IMG = "images/game_menu_book.jpg"
local POPUP_WIDTH = 750
local POPUP_HEIGHT = 895
local SPACING_LARGE = 75
local SPACING_SMALL = 50
local TEXT_PADDING = 20

function user_info_popup.new(user, parentScene, authUser, showPlayGame, onDestroy)
    local userInfoPopup = {
        user = user,
        parentScene = parentScene,
        authUser = authUser,
        showPlayGame = showPlayGame,
        onDestroy = onDestroy
    }
    return setmetatable(userInfoPopup, user_info_popup_mt)
end

function user_info_popup:render()
    if not self.user or not self.user.username then
        print("Error - cannot render userInfoPopup with invalid user: " .. json.encode(self.user))
        return nil
    end

    self.view = display.newGroup()
    self.view.alpha = 0
    self.view.x, self.view.y = display.contentWidth / 2, display.contentHeight / 2 - POPUP_HEIGHT / 2

    self.screen = self:createScreen()

    self.background = self:createBackground()
    self.background.x, self.background.y = 0, POPUP_HEIGHT / 2
    self.infoTextGroup = self:createInfoTextGroup()

    self.view:insert(self.screen)
    self.view:insert(self.background)
    self.view:insert(self.infoTextGroup)

    if self.showPlayGame and self.authUser.id ~= self.user.id then
        self.playButton = self:createPlayButton()
        self.view:insert(self.playButton)
    end

    self:show()

    return self.view
end

function user_info_popup:show()
    if self.view then
        transition.fadeIn(self.view, { time = 1000 })
    end
end

function user_info_popup:destroy()
    if self.view then
        if self.onDestroy then
            self.onDestroy()
        end
        local function onComplete()
            if not self.view then
                print("Error - attempt to destroy user_info_popup with no self.view field")
                return
            end
            self.view:removeSelf()

            self.view, self.screen, self.background, self.infoTextGroup, self.playButton = nil, nil, nil, nil, nil
        end
        transition.fadeOut(self.view, { time = 1000, onComplete = onComplete, onCancel = onComplete })
    end
end

function user_info_popup:createBackground()
    return display.newImageRect(POPUP_IMG, POPUP_WIDTH, POPUP_HEIGHT)
end

function user_info_popup:createScreen()
    local screen = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    screen:setFillColor(0, 0, 0)
    screen.alpha = 0.3
    screen.x, screen.y = 0, POPUP_HEIGHT / 2

    local that = self
    screen:addEventListener("touch", function(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "ended" then
            display.getCurrentStage():setFocus(nil)
            that:destroy()
        elseif event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end)

    screen:addEventListener("tap", function(event)
        return true
    end)

    return screen
end

function user_info_popup:createInfoTextGroup()
    local user = self.user

    local group = display.newGroup()
    local title = self:createTitle(group, user.username, SPACING_LARGE)

    local dateJoinedKey = self:createTextInfo(true, group, "Joined on", SPACING_LARGE * 2)
    local dateJoinedText = os.date("%B %d, %Y", math.floor(user.dateJoined / 1000))
    local dateJoinedValue = self:createTextInfo(false, group, dateJoinedText, SPACING_LARGE * 2)

    local winsKey = self:createTextInfo(true, group, "Wins", SPACING_LARGE * 2 + SPACING_SMALL)
    local winsValue = self:createTextInfo(false, group, tostring(user.wins), SPACING_LARGE * 2 + SPACING_SMALL)

    local lossesKey = self:createTextInfo(true, group, "Losses", SPACING_LARGE * 2 + SPACING_SMALL * 2)
    local lossesValue = self:createTextInfo(false, group, tostring(user.losses), SPACING_LARGE * 2 + SPACING_SMALL * 2)

    local tiesKey = self:createTextInfo(true, group, "Ties", SPACING_LARGE * 2 + SPACING_SMALL * 3)
    local tiesValue = self:createTextInfo(false, group, tostring(user.ties), SPACING_LARGE * 2 + SPACING_SMALL * 3)

    local ratingKey = self:createTextInfo(true, group, "Rating", SPACING_LARGE * 2 + SPACING_SMALL * 4)
    local ratingValue = self:createTextInfo(false, group, tostring(user.rating), SPACING_LARGE * 2 + SPACING_SMALL * 4)

    group:insert(title)

    return group
end

function user_info_popup:createTitle(parent, text, y)
    local usernameText = display.newText {
        parent = parent,
        y = y,
        text = text,
        font = fonts.BOLD_FONT,
        fontSize = 48
    }
    usernameText:setFillColor(1, 1, 1)
    return usernameText
end

function user_info_popup:createTextInfo(isKey, parent, text, y, font, fontSize)
    local text = display.newText {
        parent = parent,
        y = y,
        text = text,
        font = font or isKey and fonts.BOLD_FONT or native.systemFont,
        fontSize = fontSize or 32,
    }
    text.anchorX = isKey and 1.0 or 0.0
    text.x = isKey and -TEXT_PADDING or TEXT_PADDING
    text:setFillColor(1, 1, 1)

    return text
end

function user_info_popup:createPlayButton()
    local button = common_ui.createButton("Play game!", POPUP_HEIGHT - 200, function()
        if self.parentScene and self.parentScene.startGameWithUser then
           self.parentScene:startGameWithUser(self.user)
        end
    end)
    button.x = 0
    return button
end


return user_info_popup


