local loadsave = require("lib.loadsave")
local system = require("system")
local composer = require("composer")

local M = {}

-- Key names for preferences.
M.PREF_SOUND = "isSoundEnabled"   -- boolean

local PREFS_FILE = "ghostwritersPrefs.json"
local VAR_NAME = "ghostwritersPrefs"

local PREF_DEFAULTS = {
    [M.PREF_SOUND] = true
}

function M.getPref(prefName)
    if not prefName then
        return nil
    end

    local prefsData = M.getPrefsData()
    if not prefsData or prefsData[prefName] == nil then
        return PREF_DEFAULTS[prefName]
    end

    return prefsData[prefName]
end

function M.savePref(prefName, value)
    if value == nil or not prefName then
        return
    end

    local prefsData = M.getPrefsData()
    prefsData[prefName] = value
    M.savePrefsData(prefsData)
end

function M.getPrefsData()
    local prefsData = composer.getVariable(VAR_NAME)
    if prefsData then
        return prefsData
    end
    prefsData = loadsave.loadTable(PREFS_FILE, system.DocumentsDirectory)
    return prefsData or {}
end

function M.savePrefsData(prefsData)
    if not prefsData then
        return
    end
    loadsave.saveTable(prefsData, PREFS_FILE, system.DocumentsDirectory)
    composer.setVariable(VAR_NAME, prefsData)
end



return M