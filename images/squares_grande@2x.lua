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
            x=18,
            y=18,
            width=180,
            height=180,

        },
        {
            -- X3
            x=216,
            y=18,
            width=180,
            height=180,

        },
        {
            -- X4
            x=414,
            y=18,
            width=180,
            height=180,

        },
        {
            -- X5
            x=612,
            y=18,
            width=180,
            height=180,

        },
    },
    
    sheetContentWidth = 810,
    sheetContentHeight = 216
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
