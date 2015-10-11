local facebook = require( "facebook" )
local json = require("json")
local login_common = require("login.login_common")
local common_ui = require("common.common_ui")

local FB_APP_ID = "909490122473535"

local M = {}

function M.loginToFacebookThenInviteUsers()
    facebook.login(FB_APP_ID, M.shareFacebookListener, { })
end

function M.inviteUsersOnFacebook()

    local user = login_common.getUser()
    local username = user.username
    local title = "Invite friends!"
    local message = username and "Play Ghostwriters and challenge me! My username is " .. username .. "."
            or "Play Ghostwriters and challenge me!"

    facebook.showDialog( "apprequests", {
        app_id = FB_APP_ID,
        title = title,
        message = message,
        --filters = "app_non_users"
    })

end

function M.shareFacebookListener(event)
    print( "event.name:" .. event.name )  --"fbconnect"
    print( "isError: " .. tostring( event.isError ) )
    print( "didComplete: " .. tostring( event.didComplete ) )
    print( "event.type:" .. event.type )  --"session", "request", or "dialog"
    --"session" events cover various login/logout events
    --"request" events handle calls to various Graph API calls
    --"dialog" events are standard popup boxes that can be displayed

    if ( "session" == event.type ) then
        --options are "login", "loginFailed", "loginCancelled", or "logout"
        if ( "login" == event.phase ) then
            print("FB login success")
            local access_token = event.token
            --code for tasks following a successful login
           M.inviteUsersOnFacebook()
        end

    elseif ( "request" == event.type ) then
        print("facebook request")
        print(json.encode(event))
        if ( not event.isError ) then
            local response = json.decode( event.response )
            --process response data here
        end

    elseif ( "dialog" == event.type ) then
        print( "dialog", event.response )
        print("Full event:")
        print(json.encode(event))
        --M.getAppRequestInfo(event.response)
        --handle dialog results here

        common_ui.createInfoModal("Invite success", "Thanks for inviting your friends!")
    end
end

function M.getAppRequestInfo(resp, accessToken)
    print("Getting app request info...")
    local requestId = M.extractRequestId(resp)
    print("Sending facebook request...")
    facebook.request(requestId, "GET")
end

function M.extractRequestId(resp)
    print("Extracting request id from: " .. tostring(resp))
    local l, r = resp:find("request=", 1, true)
    print("l, r =" .. tostring(l) .. ", " .. tostring(r))
    local requestId = resp:sub(r + 1)
    print("requestId=" .. tostring(requestId))
    return requestId
end


return M

