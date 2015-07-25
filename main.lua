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

-- Pre-load the spritesheets needed for drawing tiles.

print("Ghostwriters started.")

one_signal_util.initOneSignal()

back_button_setup.setupDefaultBackListener()

-- There are too many issues with retaining previous scenes in memory
composer.recycleOnSceneChange = true
composer.gotoScene("scenes.loading_scene")

-- Initialize animation ahead of time so that it appers smoother.
word_spinner_class.initialize()