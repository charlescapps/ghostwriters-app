--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:522fc61649758182a1fe541213961a83:c378b044df5325d9f0e9cdb75e86d816:763e0b3cadae6c60ac1cd1029bdc34b8$
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
            x=26,
            y=26,
            width=130,
            height=130,

        },
        {
            -- X3
            x=182,
            y=26,
            width=130,
            height=130,

        },
        {
            -- X4
            x=338,
            y=26,
            width=130,
            height=130,

        },
        {
            -- X5
            x=494,
            y=26,
            width=130,
            height=130,

        },
    },
    
    sheetContentWidth = 650,
    sheetContentHeight = 182
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
