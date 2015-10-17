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
local system_helpers = require("globals.system_helpers")

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
       print("==== applicationResume event")
       system_helpers.resumeAll()
       local currentSceneName = composer.getSceneName("current")
       if currentSceneName == "scenes.play_game_scene" then
           print("applicationResume - play_game_scene")

           local currentScene = composer.getScene(currentSceneName)
           if not currentScene then
               return
           end

           local currentGame = current_game.currentGame
           if type(currentGame) ~= "table" then
               return
           end

           if currentGame.gameType == "TWO_PLAYER" then
               print("applicationResume TWO_PLAYER game - refreshing game from server!")
               if type(currentScene.refreshGameFromServer) == "function" then
                   print("applicationResume event - refreshing game from server")
                   currentScene:refreshGameFromServer()
               end

               if type(currentScene.startPollForGame) == "function" then
                   print("applicationResume event - resuming poll for game")
                   currentScene:startPollForGame()
               end
           end

           if type(currentScene.enableAllInteraction) == "function" then
               currentScene:enableAllInteraction()
           end

       elseif currentSceneName == "scenes.my_active_games_scene" then
           print("applicationResume - my_active_games_scene")
           local currentScene = composer.getScene(currentSceneName)
           if currentScene and type(currentScene.createMyGamesViewAndQuery) == "function"
                   and currentScene.creds and currentScene.creds.user then
               print("applicationResume event - refreshing My Games scene from server")
               currentScene:createMyGamesViewAndQuery(currentScene.creds.user)
           end
       end

    elseif event.type == "applicationSuspend" then
        print("==== applicationSuspend event")
        system_helpers.pauseAll()
        local currentSceneName = composer.getSceneName("current")
        print("==== currentSceneName = " .. tostring(currentSceneName))
        if currentSceneName == "scenes.play_game_scene" then
            local currentScene = composer.getScene(currentSceneName)
            if not currentScene then
                return
            end

            if type(currentScene.cancelPollForGame) == "function" then
                currentScene:cancelPollForGame()
            end
        end
    end
end

Runtime:addEventListener("system", onSystemEvent)