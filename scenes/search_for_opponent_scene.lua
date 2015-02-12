local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()
local common_api = require("common.common_api")
local common_ui = require("common.common_ui")
local login_common = require("login.login_common")

local MAX_RESULTS = 20

local userResultRows = {}

local function onSearchFail(event)
    print "Error searching for users."
end

local function createScrollViewForSearchResults()
    return widget.newScrollView
    {
        top = 300,
        left = 75,
        width = 600,
        height = 400,
        scrollWidth = 600,
        scrollHeight = 800,
        horizontalScrollDisabled = true,
        verticalScrollDisabled = false,
        topPadding = 20,
        bottomPadding = 20,
        listener = scrollListener
    }
end

local function getBackgroundColor(i)
    if i % 2 == 0 then
        return  {0.9, 0.6, 0.6}
    else
        return {0.9, 0.9, 0.9 }
    end
end

local function deselectAllUsers()
    for i = 1, #userResultRows do
        local obj = userResultRows[i]
        if obj and obj.i and obj.isSelected then
            obj.isSelected = nil
            local bg = getBackgroundColor(obj.i)
            obj:setFillColor( bg[1], bg[2], bg[3] )
        end
    end

end

local function createUserEntryView(i, user, scrollView)
    local y = (i - 1) * 45 + 25
    local userView =  display.newText({
                text = user.username,
                font = native.systemFont,
                fontSize = 40,
                x = scrollView.width / 2,
                y = y
            })
        userView:setFillColor( 0, 0, 0 )
        userView.user = user
    
    local backgroundRect = display.newRoundedRect( scrollView.width / 2, y, scrollView.width - 10, 45, 10 )
    backgroundRect.i = i
    local bg = getBackgroundColor(i)
    backgroundRect:setFillColor( bg[1], bg[2], bg[3] )

    function backgroundRect:touch(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus( self )
            self.isFocus = true
        elseif self.isFocus and event.phase == "ended" then
            deselectAllUsers()
            self.isSelected = true
            self:setFillColor( 0.6, 0.6, 0.6 )
            display.getCurrentStage():setFocus( nil )
            self.isFocus = nil
        end
        return true
    end

    backgroundRect:addEventListener( "touch", backgroundRect )

    scrollView:insert(backgroundRect)
    scrollView:insert(userView)

    userResultRows[#userResultRows + 1] = backgroundRect
end

-- Callback for successful API call to GET /users?q={query}&maxResults=20
local function onSearchSuccess(users)
    local sceneGroup = scene.view
    local searchBarGroup = sceneGroup.searchBarGroup

    userResultRows = {}
    local prevScrollView = searchBarGroup.scrollView
    prevScrollView:removeSelf()

    local scrollView = createScrollViewForSearchResults()
    searchBarGroup.scrollView = scrollView

    for i = 1, #users do
        local user = users[i]
        local userView = createUserEntryView(i, user, scrollView)
    end
end


local function userInputListener(event)

    if ( event.phase == "began" ) then
        -- user begins editing defaultField

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- do something with defaultField text
        if not event.target.text or event.target.text:len() < 2 then 
            return true
        end

        local textEntered = event.target.text
        print("User entered: " .. textEntered )
        common_api.searchForUsers(textEntered, MAX_RESULTS, onSearchSuccess, onSearchFail)

    elseif ( event.phase == "editing" ) then
        -- print( event.newCharacters )
        -- print( event.oldText )
        -- print( event.startPosition )
        -- print( event.text )
    end

end

-- ScrollView listener
local function scrollListener( event )

    local phase = event.phase
    if ( phase == "began" ) then print( "Scroll view was touched" )
    elseif ( phase == "moved" ) then print( "Scroll view was moved" )
    elseif ( phase == "ended" ) then print( "Scroll view was released" )
    end

    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then print( "Reached top limit" )
        elseif ( event.direction == "down" ) then print( "Reached bottom limit" )
        elseif ( event.direction == "left" ) then print( "Reached left limit" )
        elseif ( event.direction == "right" ) then print( "Reached right limit" )
        end
    end

    return true
end


local function createSearchBar() 
    local searchBarGroup = display.newGroup( )
    local title = display.newText( { 
        parent = searchBarGroup, 
        text = "Search for rivals", 
        x = display.contentWidth / 2, 
        y = 150, 
        font = native.systemBoldFont, 
        fontSize = 48
        } )
    title:setFillColor(0, 0, 0)
    local input = native.newTextField( display.contentWidth / 2, 250, 600, 50 )
    input:addEventListener( "userInput", userInputListener )
    input.size = 18
    input.placeholder = "Rival's username"
    input.align = "center"

    local searchIcon = display.newImageRect( searchBarGroup, "images/search-icon.png", 50, 50 )
    searchIcon.x = display.contentWidth / 2 + 325
    searchIcon.y = 250

    local scrollView = createScrollViewForSearchResults()

    searchBarGroup:insert( input )
    searchBarGroup:insert( scrollView )

    searchBarGroup.input = input
    searchBarGroup.scrollView = scrollView

    return searchBarGroup

end

local function createStartGameButton()
    return common_ui.create_button("Start a game", "start_game_button", 900, function(event)
            if ( "ended" == event.phase ) then
                print( "Button was pressed and released" )

                local selectedUser = scene.selectedUser
                if not selectedUser then
                    print "No user selected, cannot start a game"
                    return
                end

            end

        end)
end

-- "scene:create()"
function scene:create(event)
    userResultRows = {}
	local sceneGroup = self.view
    local background = common_ui.create_background()
    local searchBarGroup = createSearchBar()
    local startGameButton = createStartGameButton()
    sceneGroup:insert( background )
    sceneGroup:insert( searchBarGroup )
    sceneGroup:insert( startGameButton )

    sceneGroup.searchBarGroup = searchBarGroup
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        scene.user = login_common.checkCredentials() -- Check if the current user is logged in.
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        native.setKeyboardFocus(sceneGroup.searchBarGroup.input )
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene