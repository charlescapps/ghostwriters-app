--
-- Created by IntelliJ IDEA.
-- User: charlescapps
-- Date: 3/10/15
-- Time: 7:09 PM
-- To change this template use File | Settings | File Templates.
--

local composer = require("composer")
local M = {}

M.goToSceneFrom = function(fromSceneName, toSceneName, effect)
    local currentScene = composer.getSceneName("current")
    if currentScene == fromSceneName then
        print("Going to scene '" .. toSceneName .. "' from '" .. fromSceneName .. "'")
        composer.gotoScene(toSceneName, effect)
    else
        print("ERROR - current scene is '" .. currentScene .. "', cannot go to '" .. toSceneName .. "' from '" .. fromSceneName .. "'")
    end
end

return M

