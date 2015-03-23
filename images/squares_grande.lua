--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:eb7cbf0a147897cfcd4bef22731d56ea:c1026151f24048e177e8fd4b2d3e93f4:2f3cca80739bb0ecf082d51e95ccf369$
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
            -- grande_x2
            x=2,
            y=2,
            width=81,
            height=81,

        },
        {
            -- grande_x3
            x=85,
            y=2,
            width=81,
            height=81,

        },
        {
            -- grande_x4
            x=168,
            y=2,
            width=81,
            height=81,

        },
        {
            -- grande_x5
            x=251,
            y=2,
            width=81,
            height=81,

        },
    },
    
    sheetContentWidth = 334,
    sheetContentHeight = 85
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
