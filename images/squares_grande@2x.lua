--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:372c34de7653166650e038df4210174e:7b01d801cbb2c1d46d07cd98800977c3:d906286d76086e5113c7797a9b336ca8$
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
