local composer = require("composer")

local M = {}

function M.onSceneDidShow(scene)
    if scene.creds then
        return
    end

    composer.gotoScene("login.logged_out_scene", "fade")
end

function M.onSceneDidHide(scene)
    if scene.creds then
        return
    end

    if scene.sceneName then
        scene.view = nil --This way we guarantee that scene:create() is called again.
        composer.removeScene(scene.sceneName, false)
    end

end

return M

