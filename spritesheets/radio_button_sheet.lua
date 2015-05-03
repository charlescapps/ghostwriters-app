--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:2125aae51ad4e11b398aed660dac36c5:197363f3f2de9633256ce3538b48bc14:852ea2d3c8d65641d1a97bc87143fd83$
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
            width=100,
            height=100,

        },
        {
            -- radio_button_open@2x
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

    ["radio_button_on"] = 1,
    ["radio_button_off"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
