--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:2f8c2ce776c0536cd0492ac5c291e913:87865a57ea7dcc9f97daca767c7dd54a:d20fbd6e6e9539e797cc07361bf83694$
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
            -- picker_wheel_bg
            x=2,
            y=2,
            width=320,
            height=222,

        },
        {
            -- picker_wheel_overlay
            x=324,
            y=2,
            width=320,
            height=222,

        },
    },
    
    sheetContentWidth = 646,
    sheetContentHeight = 226
}

SheetInfo.frameIndex =
{

    ["picker_wheel_bg"] = 1,
    ["picker_wheel_overlay"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
