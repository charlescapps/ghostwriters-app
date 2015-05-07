--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:b6ffbc91977a8fa64bb576019687efd3:c378b044df5325d9f0e9cdb75e86d816:09d294fe94c5eb23b3802926c0379182$
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

    ["X2"] = 1,
    ["X3"] = 2,
    ["X4"] = 3,
    ["X5"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
