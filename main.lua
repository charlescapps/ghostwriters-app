-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local back_button_setup = require("android.back_button_setup")
local composer = require( "composer" )
local one_signal_util = require("push.one_signal_util")

print("Words with rivals app started...")

--print("Available fonts: " .. json.encode(native.getFontNames()))
one_signal_util.initOneSignal()

composer.gotoScene("scenes.loading_scene")

back_button_setup.setupBackButtonListener(nil, nil)
