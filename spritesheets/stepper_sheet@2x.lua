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
            x=4,
            y=4,
            width=340,
            height=170,

        },
        {
            -- stepper_minus_active
            x=348,
            y=4,
            width=340,
            height=170,

        },
        {
            -- stepper_no_minus
            x=692,
            y=4,
            width=340,
            height=170,

        },
        {
            -- stepper_no_plus
            x=1036,
            y=4,
            width=340,
            height=170,

        },
        {
            -- stepper_plus_active
            x=1380,
            y=4,
            width=340,
            height=170,

        },
    },
    
    sheetContentWidth = 1724,
    sheetContentHeight = 178
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
