local loadsave = require("lib.loadsave")
local system = require("system")

local M = {}

local DEVICE_ID_FILE = "ghostwritersDeviceId.txt"

function M.getDeviceId()
    local deviceId = loadsave.loadTable(DEVICE_ID_FILE, system.DocumentsDirectory)
    if not deviceId or deviceId:len() <= 0 then
        deviceId = system.getInfo("deviceID")
        print("No deviceId found stored in Ghostwriters file. Got deviceId from device.")
        M.saveDeviceId(deviceId)
    end
    return deviceId
end

function M.saveDeviceId(deviceId)
    if not deviceId or deviceId:len() <= 0 then
        print("ERROR - deviceId is empty, cannot save to file: " .. tostring(deviceId))
        return
    end

    print("Storing deviceId to file:" .. tostring(deviceId))
    loadsave.saveTable(deviceId, DEVICE_ID_FILE, system.DocumentsDirectory)
end


return M

