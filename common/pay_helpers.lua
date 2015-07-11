local system = require("system")
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local login_common = require("login.login_common")
local json = require("json")
local purchase_store = require("common.purchase_store")
local table = require("table")

local store
local googleIAP = false
local productList
local productsFromStore

local M = {}
M.onRegisterPurchaseSuccess = nil

local BOOK_PACK_1 = "book_pack_1"
local BOOK_PACK_2 = "book_pack_2"
local BOOK_PACK_3 = "book_pack_3"
local INFINITE_BOOKS = "infinite_books"

-- List of Ghostwriters "products" for IAP
local PRODUCT_LIST = {
    BOOK_PACK_1,
    BOOK_PACK_2,
    BOOK_PACK_3,
    INFINITE_BOOKS
}

local consumableProductList = {
    BOOK_PACK_1,
    BOOK_PACK_2,
    BOOK_PACK_3
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
        print("productIdentifier:", transaction.productIdentifier)
        print("receipt:", transaction.receipt)
        print("signature:", transaction.signature)
        print("transactionIdentifier:", transaction.identifier)
        print("date:", transaction.date)

        local purchaseModel = {
            isGoogle = googleIAP,
            product = transaction.productIdentifier,
            identifier = transaction.identifier,
            signature = transaction.signature
        }

        purchase_store.addPurchase(purchaseModel)

        M.registerAllPurchases()

    elseif transaction.state == "consumed" then
        print("Product consumed: " .. tostring(transaction.productIdentifier) )
    elseif (transaction.state == "cancelled") then
        M.setOnRegisterPurchaseSuccess(nil)
        --handle a cancelled transaction here

    elseif (transaction.state == "failed") then
        M.setOnRegisterPurchaseSuccess(nil)
        --handle a failed transaction here
    end

    --tell the store that the transaction is complete!
    --if you're providing downloadable content, do not call this until the download has completed
    store.finishTransaction(event.transaction)
end

function M.setOnRegisterPurchaseSuccess(listener)
    M.onRegisterPurchaseSuccess = listener
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
    store.loadProducts(PRODUCT_LIST, function(products)
        print("Loaded Products:")
        local jsonStr = json.encode(products)
        print(jsonStr)
        productsFromStore = products
    end)
end

function M.purchase(productIdentifier, onRegisterPurchaseSuccess)
    if not store then
        print("No store has been initialized...cannot purchase in-app product")
        return
    end
    local creds = login_common.fetchCredentials()
    if creds and creds.user and creds.user.infiniteBooks then
        common_ui.createInfoModal("Infinite Books!", "You have infinite books, no need to purchase anything!")
        return
    end

    -- Try to register existing purchases (and consume them for Google).
    M.registerAllPurchases()

    M.setOnRegisterPurchaseSuccess(onRegisterPurchaseSuccess)

    print("Calling store.purchase() on product: " .. productIdentifier)
    if googleIAP then
        store.purchase(productIdentifier)
    else
        store.purchase( { productIdentifier } )
    end
end

function M.registerAllPurchases()
    if not store or not store.isActive then
        print("Store not initialized, cannot consume purchases")
        return
    end

    print("Registering all purchases stored locally with the Ghostwriters server...")
    local purchaseJSON = purchase_store.loadPurchaseTable()
    local purchases = purchaseJSON.purchases

    if #purchases <= 0 then
        print("No stored purchases. Nothing to register.")
        if googleIAP then
           print("Consuming all consumable purchases: " .. table.concat(consumableProductList, ","))
           store.consumePurchase(consumableProductList, M.transactionListener)
        end
        return
    end

    local firstPurchase = purchases[1]

    local function onSuccess(updatedUserModel)
        print("Register Purchase SUCCESS - received updated user model from server.")
        login_common.updateStoredUser(updatedUserModel)
        local updatedJSON = purchase_store.removePurchase(firstPurchase)
        -- Must consume Google purchases
        if googleIAP then
            print("Consuming Google Purchase for product: " .. firstPurchase.product)
            store.consumePurchase({ firstPurchase.product }, M.transactionListener)
        end

        -- If we successfully removed something from the purchase store, but there are more purchases to register..
        -- then continue registering purchases recursively.
        if #updatedJSON.purchases < #purchases and #updatedJSON.purchases > 0 then
           M.registerAllPurchases()
        else
            if type(M.onRegisterPurchaseSuccess) == "function" then
                M.onRegisterPurchaseSuccess()
                M.setOnRegisterPurchaseSuccess(nil)
            end
        end


    end

    local function onFail()
        print("Failure registering purchase...not consuming / removing from local purchase store.")
        M.setOnRegisterPurchaseSuccess(nil)
    end

    common_api.registerPurchase(firstPurchase, onSuccess, onFail)

end

-- Initialize the "store" object
if (system.getInfo("platformName") == "Android") then
    store = require("plugin.google.iap.v3")
    googleIAP = true
    productList = PRODUCT_LIST
    store.init("google", M.transactionListener)
elseif (system.getInfo("platformName") == "iPhone OS") then
    store = require("store")
    googleIAP = false
    productList = PRODUCT_LIST -- Change this for Apple?
    store.init("apple", M.transactionListener)
else
    print("In-app purchases are not supported in the Corona Simulator.")
end



return M

