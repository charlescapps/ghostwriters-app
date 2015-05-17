local composer = require("composer")
local current_game = require("globals.current_game")
local app_state = require("globals.app_state")

local M = {}

function M.goToSceneFrom(fromSceneName, toSceneName, effect)
    local currentScene = composer.getSceneName("current")
    if currentScene == fromSceneName then
        print("Going to scene '" .. toSceneName .. "' from '" .. fromSceneName .. "'")
        composer.gotoScene(toSceneName, effect)
    else
        print("ERROR - current scene is '" .. currentScene .. "', cannot go to '" .. toSceneName .. "' from '" .. fromSceneName .. "'")
    end
end

function M.goToGame(gameModel, fromScene)
    if not gameModel then
        print("Error - cannot go to a nil game")
        return
    end
    local currentScene = composer.getSceneName("current")
    if fromScene and currentScene ~= fromScene then
        print("Cannot go to game from current scene '" .. currentScene .. "', expected " .. fromScene)
        return
    elseif currentScene == "scenes.play_game_scene" then
        app_state:setMainMenuListener(function()
            current_game.currentGame = gameModel
            composer.gotoScene("scenes.play_game_scene", "fade")
        end)
        composer.gotoScene("scenes.loading_scene")
    else
        current_game.currentGame = gameModel
        composer.gotoScene("scenes.play_game_scene", "fade")
    end
end


return M

