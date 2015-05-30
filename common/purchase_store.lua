local loadsave = require("lib.loadsave")
local json = require("json")
local table = require("table")
local system = require("system")

local M = {}

local PURCHASES_FILE = "ghostwritersPurchases.json"

function M.addPurchase(purchase)
    if not purchase or not purchase.product or not purchase.identifier then
        print("Can't add an empty purchase to the purchase store!")
        print("Invalid purchase: " .. json.encode(purchase))
        return
    end

    local purchaseJSON = M.loadPurchaseTable()

    purchaseJSON.purchases[#purchaseJSON.purchases + 1] = purchase
    M.savePurchaseTable(purchaseJSON)

    return purchaseJSON
end

function M.removePurchase(purchase)
    if not purchase then
        print("Can't add an empty purchase to the purchase store!")
        return
    end
    local purchaseJSON = M.loadPurchaseTable()

    local foundIndex
    for i = 1, #purchaseJSON.purchases do
        local p = purchaseJSON.purchases[i]
        if p.product == purchase.product and p.identifier == purchase.identifier then
            print("Removing existing purchase at index " .. tostring(i))
            foundIndex = i
            break
        end
    end

    if not foundIndex then
        print("Failed to find a purchase to remove from the purchases.")
        print("Searching for:" .. json.encode(purchase))
        print("Actual purchases:" .. json.encode(purchaseJSON))
        return
    end

    table.remove(purchaseJSON.purchases, foundIndex)
    M.savePurchaseTable(purchaseJSON)
    return purchaseJSON
end

function M.loadPurchaseTable()
    local purchaseJSON = loadsave.loadTable(PURCHASES_FILE, system.DocumentsDirectory)
    if not purchaseJSON or not purchaseJSON.purchases then
        purchaseJSON = {
            purchases = { }
        }
    end
    print("Found purchases stored on device:" .. json.encode(purchaseJSON))
    return purchaseJSON
end

function M.savePurchaseTable(purchaseJSON)
    print("Storing purchases on device:" .. json.encode(purchaseJSON))
    loadsave.saveTable(purchaseJSON, PURCHASES_FILE, system.DocumentsDirectory)
end

return M