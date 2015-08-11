local display = require("display")
local common_ui = require("common.common_ui")
local back_button_setup = require("android.back_button_setup")
local sheet_helpers = require("globals.sheet_helpers")
local transition = require("transition")

local word_spinner_class = {}
local word_spinner_class_mt = { __index = word_spinner_class }

-- Constants
local SPRITESHEET_NAME = "loading_animation"
local SEQUENCE_NAME = "loading_ghostwriters"

function word_spinner_class.initialize()
    if word_spinner_class.view then
        return
    end

    word_spinner_class.view = display.newGroup()
    word_spinner_class.view.alpha = 0

    word_spinner_class.sprite = word_spinner_class.createSprite()
    word_spinner_class.logo = word_spinner_class.drawGhostwritersLogo()
    word_spinner_class.screen = common_ui.drawScreen()

    word_spinner_class.view:insert(word_spinner_class.screen)
    word_spinner_class.view:insert(word_spinner_class.sprite)
    word_spinner_class.view:insert(word_spinner_class.logo)
end

function word_spinner_class.createSprite()

    local sheetObj = sheet_helpers:getSheetObj(SPRITESHEET_NAME)
    local spriteSheet = sheetObj.imageSheet

    -- Create the widget
    local sprite = display.newSprite(spriteSheet, {
        name = SEQUENCE_NAME,
        start = 1,
        count = 21,
        time = 2000,
        loopDirection = "bounce"
    })

    sprite.x = display.contentCenterX
    sprite.y = display.contentCenterY

    return sprite
end

function word_spinner_class.drawGhostwritersLogo()
    local img = display.newImageRect("images/ghostwriters_title.png", 750, 175)
    img.x = display.contentCenterX
    img.y = 300
    return img
end

function word_spinner_class.start()
    if not word_spinner_class.view then
        word_spinner_class.initialize()
    end

    word_spinner_class.isStopped = nil

    word_spinner_class.view:toFront()
    word_spinner_class.sprite:setSequence()
    word_spinner_class.sprite:play()

    word_spinner_class.view.alpha = 1
    --transition.fadeIn(word_spinner_class.view, { time = 100 })

    back_button_setup.setupDefaultBackListener()
end

function word_spinner_class.stop()
    if word_spinner_class.isStopped then
        return
    end

    if not word_spinner_class.view then
        return
    end

    word_spinner_class.isStopped = true

    local function onComplete()
        word_spinner_class.view.alpha = 0
        word_spinner_class.sprite:pause()
    end

    transition.fadeOut(word_spinner_class.view, { time = 200, onComplete = onComplete, onCancel = onComplete } )

    back_button_setup.restoreBackButtonListenerCurrentScene()
end


return word_spinner_class

