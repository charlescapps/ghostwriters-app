local system = require("system")
local table = require("table")
local common_api = require("common.common_api")
local login_common = require("login.login_common")
local json = require("json")
local store
local googleIAP = false
local productList
local productsFromStore

local M = {}

-- List of Ghostwriters "products" for IAP
local googleProductList = {
    "book_pack_1",
    "book_pack_2",
    "book_pack_3",
    "infinite_books"
}

function M.transactionListener(event)
    print("Event in transactionListener=" .. json.encode(event))
    if not event then
        return
    end
    local transaction = event.transaction
    if not transaction then
        print("No transaction in consumeListener!")
        return
    end

    local transaction = event.transaction

    print("Transaction state = " ..  tostring(transaction.state))

    if transaction.state == "purchased" or transaction.state == "restored" then
        --handle a successful transaction here
        print("productIdentifier", transaction.productIdentifier)
        print("receipt", transaction.receipt)
        print("signature:", transaction.signature)
        print("transactionIdentifier", transaction.identifier)
        print("date", transaction.date)

        if googleIAP then
            M.handleGooglePurchase(transaction, true)
        else
            M.handleApplePurchase(transaction, true)
        end

    elseif transaction.state == "consumed" then
        print("Product consumed: " .. transaction.productIdentifier)
    elseif (transaction.state == "cancelled") then

        --handle a cancelled transaction here

    elseif (transaction.state == "failed") then

        --handle a failed transaction here
    end

    --tell the store that the transaction is complete!
    --if you're providing downloadable content, do not call this until the download has completed
    store.finishTransaction(event.transaction)
end

function M.consumeListener(event)
    print("Event in consumeListener=" .. json.encode(event))
    if not event then
        return
    end
    local transaction = event.transaction
    if not transaction then
        print("No transaction in consumeListener!")
        return
    end

    print("Consume listener transaction state = " .. tostring(transaction.state))
    if transaction.state == "consumed" then
        print("Product consumed: " .. transaction.productIdentifier)
        M.handleGooglePurchase(transaction, false)
    end
end

function M.loadStoreProducts()
    print("Loading store products...")
    if not store then
        print("Store hasn't been created. Can't load products.")
        return
    elseif not store.isActive then
        print("Store isn't initialized. Can't load products.")
        return;
    elseif not googleIAP then
        print("Consuming previous purchases only necessary for Google IAP.")
        return
    end
    store.loadProducts(googleProductList, function(products)
        print("Loaded Products:")
        local jsonStr = json.encode(products)
        print(jsonStr)
        productsFromStore = products
    end)
end

function M.purchase(productIdentifier)
    if not store then
        print("No store has been initialized...cannot purchase in-app product")
        return
    end
    print("Calling store.purchase() on product: " .. productIdentifier)
    store.purchase(productIdentifier)
end

function M.handleGooglePurchase(transaction, doConsume)
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
        if doConsume then
            store.consumePurchase({productIdentifier}, M.transactionListener)
        end
        login_common.updateStoredUser(updatedUserModel)
    end

    local function onFail()
        print("Register Purchase FAIL")
    end

    common_api.registerPurchase(purchaseModel, onSuccess, onFail)
end

function M.consumeAllPurchases()
    if not store or not store.isActive then
        print("Store not initialized, cannot consume purchases")
        return
    end
    if not googleIAP then
        print("Can only consume Google purchases")
        return
    end
    print("Calling store.consumePurchase()")
    store.consumePurchase({"book_pack_1", "book_pack_2", "book_pack_3"}, M.consumeListener)
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

