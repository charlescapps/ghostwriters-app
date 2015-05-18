local system = require("system")
local table = require("table")
local common_api = require("common.common_api")
local login_common = require("login.login_common")
local store
local googleIAP = false
local productList = nil

local M = {}

-- List of Ghostwriters "products" for IAP
local googleProductList = {
    "book_pack_1",
    "book_pack_2",
    "book_pack_3",
    "infinite_books"
}

M.GOOGLE_BOOK_PACK_1 = "book_pack_1"

function M.transactionListener(event)
    local transaction = event.transaction

    if (transaction.state == "purchased") then

        --handle a successful transaction here
        print("productIdentifier", transaction.productIdentifier)
        print("receipt", transaction.receipt)
        print("signature:", transaction.signature)
        print("transactionIdentifier", transaction.identifier)
        print("date", transaction.date)

        if googleIAP then
            M.handleGooglePurchase(transaction)
        else
            M.handleApplePurchase(transaction)
        end

    elseif (transaction.state == "cancelled") then

        --handle a cancelled transaction here

    elseif (transaction.state == "failed") then

        --handle a failed transaction here
    end

    --tell the store that the transaction is complete!
    --if you're providing downloadable content, do not call this until the download has completed
    store.finishTransaction(event.transaction)
end

function M.handleGooglePurchase(transaction)
    print("Handling Google purchase...")
    local productIdentifier = transaction.productIdentifier
    if table.indexOf(googleProductList, productIdentifier) == nil then
        print("ERROR - product '" .. tostring(productIdentifier) .. "' isn't a valid product!")
        return
    end

    local purchaseModel = {
        isGoogle = true,
        product = productIdentifier,
        identifier = transaction.identifier,
        signature = transaction.signature
    }

    local function onSuccess(updatedUserModel)
        print("Register Purchase SUCCESS - received updated user model from server.")
        login_common.updateStoredUser(updatedUserModel)
    end

    local function onFail()
        print("Register Purchase FAIL")
    end

    common_api.registerPurchase(purchaseModel, onSuccess, onFail)
end

function M.handleApplePurchase(transaction)
    local productIdentifier = transaction.productIdentifier
end

-- Initialize the "store" object
if (system.getInfo("platformName") == "Android") then
    store = require("plugin.google.iap.v3")
    googleIAP = true
    productList = googleProductList
    store.init("google", M.transactionListener)
elseif (system.getInfo("platformName") == "iPhone OS") then
    store = require("store")
    googleIAP = false
    productList = googleProductList -- Change this for Apple?
    store.init("apple", M.transactionListener)
else
    print("In-app purchases are not supported in the Corona Simulator.")
end



return M

