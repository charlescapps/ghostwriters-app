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
