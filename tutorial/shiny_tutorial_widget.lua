local display = require("display")
local tips_modal = require("tips.tips_modal")
local common_ui = require("common.common_ui")
local json = require("json")
local fonts = require("globals.fonts")

local BUBBLE_PADDING_X = 50
local BUBBLE_PADDING_Y = 100

--[[
-- This is a widget used the first time a user plays Ghostwriters.
-- It creates a black screen covering up everything, except for the "focusedDisplayObj", which is made brighter.
-- A tip is also displayed.
-- ]]
local M = {}
local meta = { __index = M }

function M.new(opts)
    opts = opts or {}
    local shiny = {
        sceneView = opts.sceneView,
        focusedDisplayObj = opts.focusedDisplayObj,
        backButton = opts.backButton,
        tipX = opts.tipX or 0,
        tipY = opts.tipY or 0,
        tipText = opts.tipText or "",
        fontSize = opts.fontSize,
        isImage = opts.isImage
    }

    return setmetatable(shiny, meta)
end

function M:showTutorial()
    if not common_ui.isValidDisplayObj(self.sceneView) or
       not common_ui.isValidDisplayObj(self.focusedDisplayObj) then
        print("[ERROR] scene view or focus obj not valid. Not displaying shiny tutorial.")
        return false
    end

    print("[INFO] Showing shiny tutorial.")


    self.tipsModal = self:drawTipsModal()

    self.screen = common_ui.drawScreen(0.65)

    self.sceneView:insert(self.screen)
    self.screen:toFront()

    self.sceneView:insert(self.tipsModal)
    self.tipsModal:toFront()

    self:highlightFocusedDisplayObj()
    self.focusedDisplayObj:toFront()

    if common_ui.isValidDisplayObj(self.backButton) then
        self.backButton:toFront()
    end

    return true

end

function M:drawTipsModal()
    local group = display.newGroup()
    local bubble = display.newImageRect("images/speech_bubble.png", 300, 300)
    local poeHead = display.newImageRect("images/head_poe.png", 300, 350)
    local text = display.newText {
        text = self.tipText,
        font = fonts.DEFAULT_FONT,
        x = 0,
        y = 0,
        width = bubble.contentWidth - BUBBLE_PADDING_X,
        height = bubble.contentHeight - BUBBLE_PADDING_Y,
        align = "center"
    }
    text:setFillColor(0, 0, 0)

    poeHead.x, poeHead.y = -poeHead.contentWidth / 4, poeHead.contentHeight / 2

    group:insert(poeHead)
    group:insert(bubble)
    group:insert(text)

    group.x, group.y = self.tipX, self.tipY

    return group
end

function M:highlightFocusedDisplayObj()
    if self.isImage then
        local focusObj = self.focusedDisplayObj

        focusObj.fill.effect = "generator.sunbeams"

        focusObj.fill.effect.posX = 0.5
        focusObj.fill.effect.posY = 0.5
        focusObj.fill.effect.aspectRatio = ( focusObj.width / focusObj.height )
        focusObj.fill.effect.seed = 0
    end

end

return M

