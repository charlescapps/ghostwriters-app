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
