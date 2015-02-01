-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local composer = require( "composer" )


print("Hello, World!!")

local title_screen = composer.loadScene( "scenes.title_scene" )
composer.gotoScene( "scenes.title_scene" , "fade" )

