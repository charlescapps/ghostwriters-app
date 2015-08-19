local audio = require("audio")
local prefs = require("prefs.prefs")

local M = {}

M.audioHandles = {}

-- Reserve channel number 1 for music!
audio.reserveChannels(1)

local MUSIC_CHANNEL = 1
local TITLE_MUSIC_FILE = "sounds/mountain-king-normalized.mp3"

-- Generic functions
function M.playMusic(file, opts)
    if not file then
        print("[ERROR] nil file given to play as sound")
        return
    end

    local isMusicEnabled = prefs.getPref(prefs.PREF_MUSIC)
    if not isMusicEnabled then
        print("[INFO] Music not enabled, so not playing title music!")
        M.stopMusic()
        return
    end

    -- Make sure we stop any paused music, so we aren't stuck in a situation where music won't ever play.
    if audio.isChannelPlaying(MUSIC_CHANNEL) then
        return
    elseif audio.isChannelPaused(MUSIC_CHANNEL) then
        M.stopMusic()
    end

    local audioHandle = M.getAudioHandle(file)

    opts = opts or {}
    opts.loops = 0
    opts.channel = MUSIC_CHANNEL
    audio.play(audioHandle, opts)
end

function M.stopMusic()
    audio.stop(MUSIC_CHANNEL)
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

-- Specific music for convenience and encapsulation

function M.playTitleMusic(opts)
    M.playMusic(TITLE_MUSIC_FILE, opts)
end

function M.preloadTitleMusic()
    M.preloadMusic(TITLE_MUSIC_FILE)
end

function M.preloadMusic(file)
    if not file then
        return
    end
    if M.audioHandles[file] then
        return
    end

    M.audioHandles[file] = audio.loadSound(file)
end

return M

