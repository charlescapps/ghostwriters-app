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
