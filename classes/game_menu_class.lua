local game_menu_class = {}
local game_menu_class_mt = { __index = game_menu_class }

local common_ui = require("common.common_ui")
local current_game = require("globals.current_game")
local display = require("display")
local widget = require("widget")
local transition = require("transition")
local nav = require("common.nav")
local native = require("native")
local fonts = require("globals.fonts")

-- Constants
local MY_SCENE = "scenes.play_game_scene";
local GAME_MENU_IMG = "images/game_menu_book.jpg"
local GAME_MENU_WIDTH = 750
local GAME_MENU_HEIGHT = 890
local CLOSE_X_WIDTH = 90


function game_menu_class.new(playGameScene, x, y, isGameOver)

    local gameMenu = setmetatable( {
        playGameScene = playGameScene,
        isGameOver = isGameOver
    }, game_menu_class_mt )

    local displayGroup = display.newGroup()
    displayGroup.x, displayGroup.y = x, y
    displayGroup.alpha = 0 -- start invisible

    gameMenu.displayGroup = displayGroup
    gameMenu.screen = gameMenu:createScreen()
    gameMenu.menuBackground = gameMenu:createMenuBackground()
    gameMenu.dictionaryButton = gameMenu:createDictionaryButton()
    gameMenu.resignButton = gameMenu:createResignButton()
    gameMenu.backToMenuButton = gameMenu:createBackToMenuButton()
    gameMenu.closeX = gameMenu:drawCloseX()

    return gameMenu

end

function game_menu_class:createMenuBackground()
    local background = display.newImageRect(self.displayGroup, GAME_MENU_IMG, GAME_MENU_WIDTH, GAME_MENU_HEIGHT)

    -- Provide touch/tap listeners so that user doesn't accidentally close menu when touching background.
    background:addEventListener("touch", function(event) return true end)
    background:addEventListener("tap", function(event) return true end)
    return background
end

function game_menu_class:isOpen()
    return self.displayGroup.alpha > 0
end

function game_menu_class:close()
    if not self.displayGroup or not self.displayGroup.removeSelf then
        return
    end
    transition.cancel(self.displayGroup)
    transition.fadeOut(self.displayGroup, {
        time = 1000
    })
end

function game_menu_class:open()
    if not self.displayGroup or not self.displayGroup.removeSelf then
        return
    end
    transition.cancel(self.displayGroup)
    transition.fadeIn(self.displayGroup, {
        time = 1000
    })
end

function game_menu_class:toggle()
    if self:isOpen() then
        self:close()
    else
        self:open()
    end
end

function game_menu_class:createScreen()
    local screen = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    screen:setFillColor(0, 0, 0)
    screen.alpha = 0.5
    self.displayGroup:insert(screen)
    local x, y = self.displayGroup:contentToLocal(display.contentWidth / 2, display.contentHeight / 2)
    screen.x, screen.y = x, y

    local gameMenu = self

    screen:addEventListener("touch", function(event)
        gameMenu:close()
        return true -- Don't allow touches propagating to underneath the menu
    end)

    screen:addEventListener("tap", function(event)
        return true
    end)

    return screen
end

function game_menu_class:createMenuButton(text, isEnabled, onRelease)
    local labelColor = isEnabled and {0.9, 0.9, 0.9} or {0.4, 0.4, 0.4}
    return widget.newButton {
        emboss = true,
        label = text,
        font = fonts.DEFAULT_FONT,
        fontSize = 60,
        labelColor = {
            default = labelColor,
            over = { 1, 1, 1 }
        },
        width = 500,
        height = 150,
        shape = "roundedRect",
        cornerRadius = 15,
        fillColor = {
            default={ 0, 0, 0, 0 },
            over={ 1, 1, 1, 0.3 }
        },
        strokeColor = { 0.96, 0.87, 0.70 },
        strokeRadius = 10,
        onRelease = onRelease
    }
end

function game_menu_class:createDictionaryButton()
    local currentGame = current_game.currentGame
    local isEnabled = true
    if not currentGame or not currentGame.specialDict then
        isEnabled = false
    end

    local dictionaryButton = self:createMenuButton("Dictionary", isEnabled, function()
        local currentGame = current_game.currentGame
        if not currentGame or not currentGame.specialDict then
           common_ui.createInfoModal("No Dictionary!", "This is a plain English game.")
           return
        end
        nav.goToSceneFrom(MY_SCENE, "scenes.dictionary_scene", "fade")
    end)

    self.displayGroup:insert(dictionaryButton)
    dictionaryButton.x, dictionaryButton.y = 0, -200
    return dictionaryButton
end

function game_menu_class:createResignButton()
    local function alertListener(event)
        if event.action == "clicked" and event.index == 1 then
            self:close()
            self.playGameScene:resign()
        end
    end

    local isEnabled = self.isGameOver ~= true
    local resignButton = self:createMenuButton("Resign match", isEnabled, function()
        native.showAlert("Resign?", "Are you sure you want to resign?", { "YES", "NO" }, alertListener)
    end)

    if not isEnabled then
        resignButton:setEnabled(false)
    end

    self.displayGroup:insert(resignButton)

    resignButton.x, resignButton.y = 0, 0
    return resignButton
end

function game_menu_class:createBackToMenuButton()
    local backToMenuButton = self:createMenuButton("Back to Main Menu", true, function()
        nav.goToSceneFrom(MY_SCENE, "scenes.title_scene", "fade")
    end)

    self.displayGroup:insert(backToMenuButton)
    backToMenuButton.x, backToMenuButton.y = 0, 200
    return backToMenuButton
end

function game_menu_class:drawCloseX()
    local function onRelease()
        self:close()
    end
    local x = -self.menuBackground.contentWidth / 2 + CLOSE_X_WIDTH + 20
    local y = -self.menuBackground.contentHeight / 2 + CLOSE_X_WIDTH
    local closeX = widget.newButton {
        x = x,
        y = y,
        width = CLOSE_X_WIDTH,
        height = CLOSE_X_WIDTH,
        defaultFile = "images/close_x_default.png",
        overFile = "images/close_x_over.png",
        onRelease = onRelease
    }
    self.displayGroup:insert(closeX)
    return closeX
end

return game_menu_class