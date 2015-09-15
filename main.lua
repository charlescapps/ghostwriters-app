-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local back_button_setup = require("android.back_button_setup")
local composer = require( "composer" )
local one_signal_util = require("push.one_signal_util")
local word_spinner_class = require("classes.word_spinner_class")
local current_game = require("globals.current_game")
local music = require("common.music")

-- Pre-load the spritesheets needed for drawing tiles.

print("Ghostwriters started.")

one_signal_util.initOneSignal()

back_button_setup.setupDefaultBackListener()

-- There are too many issues with retaining previous scenes in memory
composer.recycleOnSceneChange = true
composer.gotoScene("scenes.loading_scene")

-- Initialize animation ahead of time so that it appers smoother.
word_spinner_class.initialize()
music.preloadAllMusic()

-- Initialize system event listener - to update the current game when game resumes
local function onSystemEvent(event)
    if event.type == "applicationResume" then
       print("applicationResume event...")
       local currentSceneName = composer.getSceneName("current")
       if currentSceneName == "scenes.play_game_scene" then
           print("applicationResume event in play_game_scene...")

           if not current_game.currentGame or current_game.currentGame.gameType ~= "TWO_PLAYER" then
               return
           end

           print("applicationResume event in TWO_PLAYER game...")
           local currentScene = composer.getScene(currentSceneName)
           if currentScene and type(currentScene.refreshGameFromServer) == "function" then
               print("applicationResume event - refreshing game from server")
               currentScene:refreshGameFromServer()
           end
       elseif currentSceneName == "scenes.my_active_games_scene" then
           print("applicationResume in my_active_games_scene...")
           local currentScene = composer.getScene(currentSceneName)
           if currentScene and type(currentScene.createMyGamesViewAndQuery) == "function"
                   and currentScene.creds and currentScene.creds.user then
               print("applicationResume event - refreshing my games scene from server")
               currentScene:createMyGamesViewAndQuery(currentScene.creds.user)
           end
       end

    end
end

Runtime:addEventListener("system", onSystemEvent)