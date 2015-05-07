--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:906b2d0401680d5bbb732a9a61952f81:7b01d801cbb2c1d46d07cd98800977c3:09d294fe94c5eb23b3802926c0379182$
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
            x=2,
            y=2,
            width=150,
            height=150,

        },
        {
            -- X3
            x=154,
            y=2,
            width=150,
            height=150,

        },
        {
            -- X4
            x=306,
            y=2,
            width=150,
            height=150,

        },
        {
            -- X5
            x=458,
            y=2,
            width=150,
            height=150,

        },
    },
    
    sheetContentWidth = 610,
    sheetContentHeight = 154
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
