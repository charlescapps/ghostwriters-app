local loadsave = require("lib.loadsave")
local system = require("system")
local json = require("json")

local M = {}

local ONE_SIGNAL_PLAYER_ID_FILE = "ghostwritersOneSignalId.json"

function M.getOneSignalInfo()
    local oneSignalInfo = loadsave.loadTable(ONE_SIGNAL_PLAYER_ID_FILE, system.DocumentsDirectory)
    if type(oneSignalInfo) ~= "table" or not oneSignalInfo.oneSignalPlayerId then
        print("[INFO] Non-existent oneSignalInfo in file.")
        return nil
    end
    return oneSignalInfo
end

function M.saveOneSignalInfo(oneSignalInfo)
    print("==== Saving oneSignalInfo to queue...")
    if type(oneSignalInfo) ~= "table" or not oneSignalInfo.oneSignalPlayerId then
        print("[ERROR] Attempt to store invalid oneSignalInfo: " .. json.encode(oneSignalInfo))
    end

    print("Storing oneSignalInfo to file:" .. json.encode(oneSignalInfo))
    loadsave.saveTable(oneSignalInfo, ONE_SIGNAL_PLAYER_ID_FILE, system.DocumentsDirectory)
end

function M.clearOneSignalInfo()
    print("==== Clearing oneSignalInfo from queue...")
    loadsave.saveTable({}, ONE_SIGNAL_PLAYER_ID_FILE, system.DocumentsDirectory)
end

return M

