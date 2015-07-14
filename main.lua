-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local back_button_setup = require("android.back_button_setup")
local composer = require( "composer" )
local one_signal_util = require("push.one_signal_util")

-- Pre-load the spritesheets needed for drawing tiles.

print("Words with rivals app started.")

one_signal_util.initOneSignal()

back_button_setup.setupDefaultBackListener()

-- There are too many issues with retaining previous scenes in memory
composer.recycleOnSceneChange = true
composer.gotoScene("scenes.loading_scene")