local facebook = require( "facebook" )
local json = require("json")
local login_common = require("login.login_common")

local FB_APP_ID = "909490122473535"

local M = {}

function M.loginToFacebook(onLoginSuccess)
    facebook.login(FB_APP_ID, M.getFacebookListener(onLoginSuccess), { "publish_actions" })
end

function M.shareToFacebook()
    -- Oops. This directly uses the FB API without any prompt!
    --facebook.request( "me/feed", "POST", { message="Hello Facebook" } )
    local user = login_common.getUser()
    local username = user.username
    local title = "Invite friends to play Ghostwriters!"
    local message = username and "Download Ghostwriters and challenge me! My username is " .. username .. "."
                              or "Download Ghostwriters and challenge me!"

    facebook.showDialog( "apprequests", {
        title = title,
        message = message
    } )
end

function M.getFacebookListener(onLoginSuccess)
    return function(event)
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
                if type(onLoginSuccess) == 'function' then
                   onLoginSuccess()
                end
            end

        elseif ( "request" == event.type ) then
            print("facebook request")
            if ( not event.isError ) then
                local response = json.decode( event.response )
                --process response data here
            end

        elseif ( "dialog" == event.type ) then
            print( "dialog", event.response )
            --handle dialog results here
        end
    end
end


return M

