local audio = require("audio")

local M = {}

M.audioHandles = {}

-- Generic functions
function M.playSound(file, opts)
    if not file then
        print("[ERROR] nil file given to play as sound")
        return
    end
    local audioHandle = M.getAudioHandle(file)
    audio.play(audioHandle, opts)
end

function M.getAudioHandle(file)
    if not file then
        return
    end

    if M.audioHandles[file] then
        return M.audioHandles[file]
    end

    M.audioHandles[file] = audio.loadSound(file)
    return M.audioHandles[file]
end

-- Specific sounds for convenience and encapsulation
function M.playStoneTileSound(opts)
    print("Playing stone tile sound!")
    M.playSound("sounds/stone-tiles.mp3", opts)
end

return M

