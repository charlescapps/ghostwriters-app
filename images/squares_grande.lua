--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:fd7e691fea697ae51d23ec62ec98d3b4:c378b044df5325d9f0e9cdb75e86d816:d906286d76086e5113c7797a9b336ca8$
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
