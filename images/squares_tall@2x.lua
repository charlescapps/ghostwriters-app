--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:0936a82660da47ff5dbbf2e59e2c46e8:9c14beac9f6abd5b7db6ec52260b1740:09d294fe94c5eb23b3802926c0379182$
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
            x=4,
            y=4,
            width=300,
            height=300,

        },
        {
            -- X3
            x=308,
            y=4,
            width=300,
            height=300,

        },
        {
            -- X4
            x=612,
            y=4,
            width=300,
            height=300,

        },
        {
            -- X5
            x=916,
            y=4,
            width=300,
            height=300,

        },
    },
    
    sheetContentWidth = 1220,
    sheetContentHeight = 308
}

SheetInfo.frameIndex =
{

    ["tall_x2"] = 1,
    ["tall_x3"] = 2,
    ["tall_x4"] = 3,
    ["tall_x5"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
