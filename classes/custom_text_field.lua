local system = require("system")
local native = require("native")
local display = require("display")
local math = require("math")
local transition = require("transition")

local M = {}

function M.newCustomTextField(options)
    local customOptions = options or {}
    local opt = {}
    opt.align = customOptions.align
    opt.left = customOptions.left or 0
    opt.top = customOptions.top or 0
    opt.x = customOptions.x or 0
    opt.y = customOptions.y or 0
    opt.width = customOptions.width or (display.contentWidth * 0.75)
    opt.height = customOptions.height or 20
    opt.padding = customOptions.passing or math.floor(opt.height / 8)
    opt.id = customOptions.id
    opt.listener = customOptions.listener or nil
    opt.placeholder = customOptions.placeholder or ""
    opt.text = customOptions.text or ""
    opt.inputType = customOptions.inputType or "default"
    opt.font = customOptions.font or native.systemFont
    opt.fontSize = customOptions.fontSize or opt.height * 0.8
    opt.isSecure = customOptions.isSecure
    opt.returnKey = customOptions.returnKey

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
    tHeight = tHeight - opt.padding * 2

    if "Android" == system.getInfo("platformName") then
        --
        -- Older Android devices have extra "chrome" that needs to be compesnated for.
        --
        tHeight = tHeight + 10
    end

    field.textField = native.newTextField( 0, 0, opt.width - opt.cornerRadius, tHeight )
    field:insert(field.textField)
    field.textField.hasBackground = false
    field.textField.inputType = opt.inputType
    field.textField.text = opt.text
    field.textField.placeholder = opt.placeholder
    field.textField.isSecure = opt.isSecure
    if opt.returnKey then
        field.textField:setReturnKey(opt.returnKey)
    end
    field.isFontSizeScaled = true
    if ( opt.listener and type(opt.listener) == "function" ) then
        field.textField:addEventListener( "userInput", opt.listener )
    end

    field.textField.font = opt.font and native.newFont( opt.font ) or native.systemFont
    field.textField.size = opt.fontSize
    field.textField.align = opt.align

    -- Remove from screen when the parent is hidden
    function field:finalize( event )
        if event.target.textField and event.target.textField.removeSelf then
            event.target.textField:removeSelf()
            event.target.textField = nil
        end
    end
    field:addEventListener( "finalize" )

    function field:getText()
        return self.textField and self.textField.text
    end

    function field:setText(text)
        if self.textField then
            self.textField.text = text
        end
    end

    function field:setPlaceholder(text)
        self.textField.placeholder = text
    end

    function field:destroy()
        if self.textField and self.textField.removeSelf then
            self.textField:removeSelf()
        end
        if self.removeSelf then
            self:removeSelf()
        end
    end

    function field:fadeOut()
        local function onCancel()
            self.alpha = 0
        end

        self.oldText = self:getText()
        self:setText("")

        transition.cancel(self)
        transition.fadeOut(self, {time = 400, onCancel = onCancel})
    end

    function field:fadeIn()
        local function onCancel()
            self.alpha = 1
        end

        transition.cancel(self)
        transition.fadeIn(self, {time = 400, onCancel = onCancel})

        self:setText(self.oldText)
    end

    field.textField:resizeFontToFitHeight()

    return field
end


return M

