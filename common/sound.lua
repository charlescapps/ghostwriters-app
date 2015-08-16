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
    M.playSound("sounds/stone-tiles.mp3", opts)
end

function M.playRavensSound(opts)
    M.playSound("sounds/ravens.mp3", opts)
end

function M.playJiggerTileSound(opts)
    M.playSound("sounds/jigger-tiles.mp3", opts)
end

function M.playPickupPaperTileSound(opts)
    M.playSound("sounds/pickup-paper-tile.mp3")
end

return M

