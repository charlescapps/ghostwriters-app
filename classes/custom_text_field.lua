local system = require("system")
local native = require("native")
local display = require("display")

local M = {}

function M.newCustomTextField(options)
    local customOptions = options or {}
    local opt = {}
    opt.left = customOptions.left or 0
    opt.top = customOptions.top or 0
    opt.x = customOptions.x or 0
    opt.y = customOptions.y or 0
    opt.width = customOptions.width or (display.contentWidth * 0.75)
    opt.height = customOptions.height or 20
    opt.id = customOptions.id
    opt.listener = customOptions.listener or nil
    opt.placeholder = customOptions.placeholder or ""
    opt.text = customOptions.text or ""
    opt.inputType = customOptions.inputType or "default"
    opt.font = customOptions.font or native.systemFont
    opt.fontSize = customOptions.fontSize or opt.height * 0.67

    -- Vector options
    opt.strokeWidth = customOptions.strokeWidth or 2
    opt.cornerRadius = customOptions.cornerRadius or opt.height * 0.33 or 10
    opt.strokeColor = customOptions.strokeColor or { 0, 0, 0 }
    opt.backgroundColor = customOptions.backgroundColor or { 1, 1, 1 }

    -- Create textfield
    local field = display.newGroup()

    local background = display.newRoundedRect( 0, 0, opt.width, opt.height, opt.cornerRadius )
    background:setFillColor( unpack(opt.backgroundColor) )
    background.strokeWidth = opt.strokeWidth
    background.stroke = opt.strokeColor
    field:insert( background )

    if ( opt.x ) then
        field.x = opt.x
    elseif ( opt.left ) then
        field.x = opt.left + opt.width * 0.5
    end
    if ( opt.y ) then
        field.y = opt.y
    elseif ( opt.top ) then
        field.y = opt.top + opt.height * 0.5
    end

    -- Native UI element
    local tHeight = opt.height - opt.strokeWidth * 2
    if "Android" == system.getInfo("platformName") then
        --
        -- Older Android devices have extra "chrome" that needs to be compesnated for.
        --
        tHeight = tHeight + 10
    end

    local deviceScale = ( display.pixelWidth / display.contentWidth ) * 0.5
    local actualFontSize = opt.fontSize * deviceScale

    field.textField = native.newTextField( 0, opt.fontSize / 2, opt.width - opt.cornerRadius, tHeight )
    field:insert(field.textField)
    field.textField.hasBackground = false
    field.textField.inputType = opt.inputType
    field.textField.text = opt.text
    field.textField.placeholder = opt.placeholder
    print( opt.listener, type(opt.listener) )
    if ( opt.listener and type(opt.listener) == "function" ) then
        print("Adding userInput listener!")
        field.textField:addEventListener( "userInput", opt.listener )
    end

    field.textField.font = opt.font and native.newFont( opt.font ) or native.systemFont
    field.textField.size = actualFontSize

    -- Remove from screen when the parent is hidden
    function field:finalize( event )
        event.target.textField:removeSelf()
    end
    field:addEventListener( "finalize" )

    function field:getText()
        return self.textField.text
    end

    function field:setText(text)
        self.textField.text = text
    end

    function field:setPlaceholder(text)
        self.textField.placeholder = text
    end

    return field
end


return M
