--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:6f4f30e0da570e9dc52c1687e41c7dc8:c934767ef90d18ed520d0fbd419f508e:0cd67ad0122fdefe810981c14726e688$
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
            -- venti_x2
            x=2,
            y=2,
            width=56,
            height=56,

        },
        {
            -- venti_x3
            x=60,
            y=2,
            width=56,
            height=56,

        },
        {
            -- venti_x4
            x=118,
            y=2,
            width=56,
            height=56,

        },
        {
            -- venti_x5
            x=176,
            y=2,
            width=56,
            height=56,

        },
    },
    
    sheetContentWidth = 234,
    sheetContentHeight = 60
}

SheetInfo.frameIndex =
{

    ["venti_x2"] = 1,
    ["venti_x3"] = 2,
    ["venti_x4"] = 3,
    ["venti_x5"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
