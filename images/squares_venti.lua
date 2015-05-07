--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:c72b84a60cb047b264a622589e06e280:7b01d801cbb2c1d46d07cd98800977c3:763e0b3cadae6c60ac1cd1029bdc34b8$
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
            x=13,
            y=13,
            width=65,
            height=65,

        },
        {
            -- X3
            x=91,
            y=13,
            width=65,
            height=65,

        },
        {
            -- X4
            x=169,
            y=13,
            width=65,
            height=65,

        },
        {
            -- X5
            x=247,
            y=13,
            width=65,
            height=65,

        },
    },
    
    sheetContentWidth = 325,
    sheetContentHeight = 91
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
