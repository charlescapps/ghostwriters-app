--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:4d63c43f81cde2743b08de7daf0a6261:81c35080313a10a5a86a4656c835b502:721e4da8a75cf2c44abe63d99e39c955$
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
            x=2,
            y=2,
            width=170,
            height=85,

        },
        {
            -- stepper_minus_active
            x=174,
            y=2,
            width=170,
            height=85,

        },
        {
            -- stepper_no_minus
            x=346,
            y=2,
            width=170,
            height=85,

        },
        {
            -- stepper_no_plus
            x=518,
            y=2,
            width=170,
            height=85,

        },
        {
            -- stepper_plus_active
            x=690,
            y=2,
            width=170,
            height=85,

        },
    },
    
    sheetContentWidth = 862,
    sheetContentHeight = 89
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
