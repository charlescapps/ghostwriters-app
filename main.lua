-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local composer = require( "composer" )
local one_signal_util = require("push.one_signal_util")

print("Words with rivals app started...")

--print("Available fonts: " .. json.encode(native.getFontNames()))
one_signal_util.initOneSignal()

composer.gotoScene( "scenes.title_scene" , "fade" )