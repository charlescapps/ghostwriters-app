local display = require("display")
local choose_game_size_and_bonus_words_tip = require("tips.create_game.choose_game_size_and_bonus_words_tip")
local choose_bonus_tiles_tip = require("tips.create_game.choose_bonus_tiles_tip")
local currency_tip = require("tips.currency_tip")
local grab_tiles_simple_tip = require("tips.all_tips.grab_tiles_simple_tip")
local play_word_simple_tip = require("tips.all_tips.play_word_simple_tip")
local game_menu_tip = require("tips.game_menu_tip")
local zoom_in_simple_tip = require("tips.all_tips.zoom_in_simple_tip")
local pass_tip = require("tips.pass_tip")
local end_game_tip = require("tips.end_game_tip")
local ranking_tip = require("tips.ranking_tip")
local play_word_alone_tip = require("tips.play_word_alone_tip")
local question_tile_simple_tip = require("tips.all_tips.question_tile_simple_tip")
local scry_tile_simple_tip = require("tips.all_tips.scry_tile_simple_tip")

local widget = require("widget")
local common_ui = require("common.common_ui")

local M = {}
local meta = { __index = M }

local ALL_TIPS = {
    grab_tiles_simple_tip,
    play_word_simple_tip,
    choose_game_size_and_bonus_words_tip,
    choose_bonus_tiles_tip,
    currency_tip,
    game_menu_tip,
    question_tile_simple_tip,
    scry_tile_simple_tip,
    zoom_in_simple_tip,
    pass_tip,
    end_game_tip,
    play_word_alone_tip,
    ranking_tip
}

function M.new()
    local allTipsWidget = {
        index = 1
    }
    return setmetatable(allTipsWidget, meta)
end

function M:render()
    self.view = display.newGroup()

    self:renderCurrentTip()

    self:drawArrowControls()

    return self.view

end

function M:drawArrowControls()

    local function onReleaseLeft()
        self:decrIndex()
        self:renderCurrentTip()
    end

    self.leftArrow = widget.newButton {
        x = 50,
        y = display.contentCenterY,
        defaultFile = "images/left_arrow.png",
        overFile = "images/left_arrow_over.png",
        width = 100,
        height = 400,
        onRelease = onReleaseLeft
    }
    self.view:insert(self.leftArrow)

    local function onReleaseRight()
        self:incrIndex()
        self:renderCurrentTip()
    end

    self.rightArrow = widget.newButton {
        x = display.contentWidth - 65,
        y = display.contentCenterY,
        defaultFile = "images/right_arrow.png",
        overFile = "images/right_arrow_over.png",
        width = 100,
        height = 400,
        onRelease = onReleaseRight
    }
    self.view:insert(self.rightArrow)

end

function M:decrIndex()
    self.index = self.index - 1
    if self.index < 1 then
        self.index = self.index + #ALL_TIPS
    end
end

function M:incrIndex()
    self.index = self.index + 1
    if self.index > #ALL_TIPS then
        self.index = self.index - #ALL_TIPS
    end
end

function M:renderCurrentTip()
    if self.index > #ALL_TIPS or self.index < 1 then
        print("[ERROR] all_tips_widget.index is out-of-bounds. Value is: " .. tostring(self.index))
       return
    end

    self:removeCurrentTip()

    local function onReleaseGotItButton()
        common_ui.fadeOutThenRemove(self.view, { time = 500 })
    end
    self.currentTip = ALL_TIPS[self.index].new(true, onReleaseGotItButton)
    local tipView = self.currentTip:renderTip()
    self.view:insert(tipView)

    self:arrowsToFront()
end

function M:removeCurrentTip()
    local currentTipsModal = self.currentTip and self.currentTip.tipsModal
    if currentTipsModal and type(currentTipsModal.destroy) == "function" then
        currentTipsModal:destroy()
    end
end

function M:arrowsToFront()
    if self.leftArrow then
        self.leftArrow:toFront()
    end

    if self.rightArrow then
        self.rightArrow:toFront()
    end
end

return M

