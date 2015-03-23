--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:27d064563c56b0f67adef55da1491e70:a78936bb20210974085688280c5647fd:63c0915c85a4efaa2d45ddc5d89392f4$
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
            -- tall_x2
            x=2,
            y=2,
            width=146,
            height=146,

        },
        {
            -- tall_x3
            x=150,
            y=2,
            width=146,
            height=146,

        },
        {
            -- tall_x4
            x=298,
            y=2,
            width=146,
            height=146,

        },
        {
            -- tall_x5
            x=446,
            y=2,
            width=146,
            height=146,

        },
    },
    
    sheetContentWidth = 594,
    sheetContentHeight = 150
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
