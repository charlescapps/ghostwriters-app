--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:3f8dbbd05e0c94b765311cfdeb81b3bd:eeff3f5394a70a104cc4048f6873364b:f8b7c63f17b1d044816fa8b1f813d266$
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
            -- checkbox_checked@2x
            x=2,
            y=2,
            width=100,
            height=100,

        },
        {
            -- checkbox_unchecked@2x
            x=104,
            y=2,
            width=100,
            height=100,

        },
    },
    
    sheetContentWidth = 206,
    sheetContentHeight = 104
}

SheetInfo.frameIndex =
{

    ["checkbox_checked"] = 1,
    ["checkbox_unchecked"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
