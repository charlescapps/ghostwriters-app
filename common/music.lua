local audio = require("audio")
local prefs = require("prefs.prefs")

local M = {}

M.audioHandles = {}

-- Reserve channel numbers 1-2 for music!
local NUM_MUSIC_CHANNELS = 2
audio.reserveChannels(NUM_MUSIC_CHANNELS)

local TITLE_MUSIC_CHANNEL = 1
local IN_GAME_MUSIC_CHANNEL = 2

local TITLE_MUSIC_FILE = "sounds/in_the_hall_of_cthulhu.mp3"
local IN_GAME_MUSIC_FILE = "sounds/fugue_for_ghosts.mp3"

-- Generic functions
function M.playMusic(file, channel, opts)
    if not file then
        print("[ERROR] nil file given to play as sound")
        return
    end
    if not channel then
        print("[ERROR] nil channel given to play as sound")
        return
    end

    local isMusicEnabled = prefs.getPref(prefs.PREF_MUSIC)
    if not isMusicEnabled then
        print("[INFO] Music not enabled, so not playing music!")
        M.stopMusic()
        return
    end

    -- Make sure we stop any paused music, so we aren't stuck in a situation where music won't ever play.
    M.pauseAllMusicChannels()

    if audio.isChannelPaused(channel) then
        audio.resume(channel)
        return
    end

    audio.stop(channel)

    local audioHandle = M.getAudioHandle(file)

    opts = opts or {}
    opts.loops = -1
    opts.channel = channel
    audio.play(audioHandle, opts)
end

function M.pauseAllMusicChannels()
    for i = 1, NUM_MUSIC_CHANNELS do
       audio.pause(i)
    end
end

function M.stopMusic()
    for i = 1, NUM_MUSIC_CHANNELS do
        audio.stop(i)
    end
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
    M.playMusic(TITLE_MUSIC_FILE, 1, opts)
end

function M.playInGameMusic(opts)
    M.playMusic(IN_GAME_MUSIC_FILE, 2, opts)
end

function M.preloadAllMusic()
    M.preloadMusic(TITLE_MUSIC_FILE)
    M.preloadMusic(IN_GAME_MUSIC_FILE)
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

