local loadsave = require("lib.loadsave")
local system = require("system")

local M = {}

local TIPS_FILE = "ghostwritersTips.json"

function M.getTipsData()
    local tipsData = loadsave.loadTable(TIPS_FILE, system.DocumentsDirectory)
    return tipsData or {}
end

function M.saveTipsData(tipsData)
    loadsave.saveTable(tipsData, TIPS_FILE, system.DocumentsDirectory)
end

function M.recordViewedTip(tipName)
    local tipsData = M.getTipsData()
    tipsData[tipName] = true
    M.saveTipsData(tipsData)
end

function M.isTipViewed(tipName)
    local tipsData = M.getTipsData()
    return tipsData[tipName]
end

return M

