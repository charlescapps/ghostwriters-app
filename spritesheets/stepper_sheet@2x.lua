--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:85a0ce27e8a6d97dfa1ba8ef3b4a7159:91cd175ccdc14d29374eb0ca5446c1b6:721e4da8a75cf2c44abe63d99e39c955$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- stepper_default
            x=4,
            y=4,
            width=260,
            height=130,

        },
        {
            -- stepper_minus_active
            x=268,
            y=4,
            width=260,
            height=130,

        },
        {
            -- stepper_no_minus
            x=532,
            y=4,
            width=260,
            height=130,

        },
        {
            -- stepper_no_plus
            x=796,
            y=4,
            width=260,
            height=130,

        },
        {
            -- stepper_plus_active
            x=1060,
            y=4,
            width=260,
            height=130,

        },
    },
    
    sheetContentWidth = 1324,
    sheetContentHeight = 138
}

SheetInfo.frameIndex =
{

    ["stepper_default"] = 1,
    ["stepper_minus_active"] = 2,
    ["stepper_no_minus"] = 3,
    ["stepper_no_plus"] = 4,
    ["stepper_plus_active"] = 5,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
