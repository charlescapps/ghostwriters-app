local common_ui = require("common.common_ui")
local display = require("display")
local tips_modal = require("tips.tips_modal")
local tips_persist = require("tips.tips_persist")
local math = require("math")
local json = require("json")
local transition = require("transition")
local timer = require("timer")
local table = require("table")

local M = {}
local meta = { __index = M }

local TIP_NAME = "scry_tile_tip"
local SCRY_TILE_TIP_TAG = "scry_tile_anim"
local MS_PER_TILE = 500

function M.new(playGameScene)
    local scryTileTip = {
        playGameScene = playGameScene,
        arrowImages = {}
    }
    return setmetatable(scryTileTip, meta)
end

function M:triggerTipOnCondition()
    if not self:isSceneValid(self.playGameScene) then
        print("ERROR - invalid play game scene, cannot trigger scry tile tip.")
        return
    end

    local gameModel = self.playGameScene.board.gameModel
    local user = self.playGameScene.creds.user

    if gameModel.player1Rack:find("^", 1, true) and gameModel.player1Turn and gameModel.player1 == user.id or
       gameModel.player2Rack:find("^", 1, true) and not gameModel.player1Turn and gameModel.player2 == user.id then
        print("Triggering scry tile tip b/c current player has a scry tile.")
        self:showTip()
    end
end

function M:showTip()
    local board = self.playGameScene.board
    if not tips_persist.isTipViewed(TIP_NAME) then
        local function onClose()
            tips_persist.recordViewedTip(TIP_NAME)
        end
        local tipsModal = tips_modal.new("Drag Scry tiles from your hand to the board.", nil, onClose,
            "images/scry_tip.png", 250, 250, 0, -40)
        tipsModal:show()
    end

end

function M:isSceneValid(playGameScene)
   return playGameScene and self:isBoardValid(playGameScene.board) and
          playGameScene.creds and playGameScene.creds.user and playGameScene.creds.user.id and true
end

function M:isBoardValid(board)
    return board and board.tileImages and board.tilesGroup and self:isGameModelValid(board.gameModel)
end

function M:isGameModelValid(gameModel)
    return gameModel and gameModel.moveNum and gameModel.player1Rack and gameModel.player2Rack and gameModel.player1 and gameModel.player2 and true
end


return M
