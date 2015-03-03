-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local composer = require( "composer" )
local native = require("native")
local json = require("json")

print("Words with rivals app started...")

print("Available fonts: " .. json.encode(native.getFontNames()))

composer.gotoScene( "scenes.title_scene" , "fade" )

