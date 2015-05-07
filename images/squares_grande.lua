--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:63df845b95309e6a3e46a9ec77fc8a0b:9c14beac9f6abd5b7db6ec52260b1740:d906286d76086e5113c7797a9b336ca8$
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
            -- X2
            x=9,
            y=9,
            width=90,
            height=90,

        },
        {
            -- X3
            x=108,
            y=9,
            width=90,
            height=90,

        },
        {
            -- X4
            x=207,
            y=9,
            width=90,
            height=90,

        },
        {
            -- X5
            x=306,
            y=9,
            width=90,
            height=90,

        },
    },
    
    sheetContentWidth = 405,
    sheetContentHeight = 108
}

SheetInfo.frameIndex =
{

    ["grande_x2"] = 1,
    ["grande_x3"] = 2,
    ["grande_x4"] = 3,
    ["grande_x5"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
