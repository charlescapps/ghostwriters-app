local back_button_setup = require("android.back_button_setup")

local M = {}

function M.onDidShowScene(scene)
    back_button_setup.setupBackButtonListener(scene.backButton)
end

function M.onWillHideScene()
    back_button_setup.setupDefaultBackListener()
end

return M

