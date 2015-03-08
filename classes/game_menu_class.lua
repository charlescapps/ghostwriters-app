local game_menu_class = {}
local game_menu_class_mt = { __index = game_menu_class }

local composer = require("composer")
local display = require("display")
local widget = require("widget")
local common_ui = require("common.common_ui")
local transition = require("transition")
local easing = require("easing")

-- Constants
local GAME_MENU_IMG = "images/game_menu_book.jpg"
local GAME_MENU_WIDTH = 750
local GAME_MENU_HEIGHT = 895

local CLOSE_X_IMG = "images/close_x.png"
local CLOSE_X_OVER_IMG = "images/close_x_dark.png"
local CLOSE_X_WIDTH = 100


function game_menu_class.new(x, y, doPass)

    local gameMenu = setmetatable( { doPass = doPass }, game_menu_class_mt )

    local displayGroup = display.newGroup()
    displayGroup.x, displayGroup.y = x, y
    displayGroup.alpha = 0.0 -- start invisible

    gameMenu.displayGroup = displayGroup
    gameMenu.menuBackground = gameMenu:createMenuBackground()
    gameMenu.backToMenuButton = gameMenu:createBackToMenuButton()
    gameMenu.dictionaryButton = gameMenu:createDictionaryButton()
    gameMenu.passButton = gameMenu:createPassButton()

    return gameMenu

end

function game_menu_class:createMenuBackground()
    return display.newImageRect(self.displayGroup, GAME_MENU_IMG, GAME_MENU_WIDTH, GAME_MENU_HEIGHT)
end

function game_menu_class:isOpen()
    return self.displayGroup.alpha > 0
end

function game_menu_class:close()
	local that = self
    transition.fadeOut(that.displayGroup, {
        time = 1000
        --transition = easing.inExpo
    })
end

function game_menu_class:open()
	local that = self
    transition.fadeIn(that.displayGroup, {
        time = 1000
        --transition = easing.inExpo
    })
end

function game_menu_class:toggle()
    if self:isOpen() then
        self:close()
    else
        self:open()
    end
end

function game_menu_class:createMenuButton(text, onRelease)
    return widget.newButton {
        emboss = true,
        label = text,
        fontSize = 60,
        labelColor = {
            default = {0.9, 0.9, 0.9},
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

function game_menu_class:createBackToMenuButton()
    local backToMenuButton = self:createMenuButton("Back to Main Menu", function()
        local currentScene = composer.getSceneName("current")
        composer.gotoScene("scenes.title_scene", "fade")
        composer.removeScene(currentScene, false)
    end)

    self.displayGroup:insert(backToMenuButton)
    backToMenuButton.x, backToMenuButton.y = 0, -200
    return backToMenuButton
end

function game_menu_class:createDictionaryButton()
    local dictionaryButton = self:createMenuButton("Dictionary", function()
        -- TODO: Create an endpoint to lookup word definitions
    end)

    self.displayGroup:insert(dictionaryButton)
    dictionaryButton.x, dictionaryButton.y = 0, 0
    return dictionaryButton
end

function game_menu_class:createPassButton()
    local passButton = self:createMenuButton("Pass", self.doPass)
    self.displayGroup:insert(passButton)
    passButton.x, passButton.y = 0, 200
    return passButton
end


return game_menu_class