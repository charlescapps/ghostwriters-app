--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:ae7d84554a7e3f4c46711e6704756851:1f22989cc1a5b8b4514c65feb495129b:852ea2d3c8d65641d1a97bc87143fd83$
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
            -- radio_button_closed@2x
            x=2,
            y=2,
            width=175,
            height=175,

        },
        {
            -- radio_button_open@2x
            x=179,
            y=2,
            width=175,
            height=175,

        },
    },
    
    sheetContentWidth = 356,
    sheetContentHeight = 179
}

SheetInfo.frameIndex =
{

    ["radio_button_closed"] = 1,
    ["radio_button_open"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
