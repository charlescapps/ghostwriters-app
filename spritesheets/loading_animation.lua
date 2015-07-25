--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:9455fb25d1ddf34b0e3e3965d3d9d7f5:d5b23abc43825d5f7e4186c55ad2395c:fdfc81a53690b3edf7d07272b02bf25f$
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
            -- Icon_Logo_00000
            x=4,
            y=4,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00001
            x=608,
            y=4,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00002
            x=1212,
            y=4,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00003
            x=1816,
            y=4,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00004
            x=2420,
            y=4,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00005
            x=3024,
            y=4,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00006
            x=4,
            y=408,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00007
            x=608,
            y=408,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00008
            x=1212,
            y=408,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00009
            x=1816,
            y=408,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00010
            x=2420,
            y=408,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00011
            x=3024,
            y=408,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00012
            x=4,
            y=812,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00013
            x=608,
            y=812,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00014
            x=1212,
            y=812,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00015
            x=1816,
            y=812,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00016
            x=2420,
            y=812,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00017
            x=3024,
            y=812,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00018
            x=4,
            y=1216,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00019
            x=608,
            y=1216,
            width=600,
            height=400,

        },
        {
            -- Icon_Logo_00020
            x=1212,
            y=1216,
            width=600,
            height=400,

        },
    },
    
    sheetContentWidth = 3628,
    sheetContentHeight = 1620
}

SheetInfo.frameIndex =
{

    ["Icon_Logo_00000"] = 1,
    ["Icon_Logo_00001"] = 2,
    ["Icon_Logo_00002"] = 3,
    ["Icon_Logo_00003"] = 4,
    ["Icon_Logo_00004"] = 5,
    ["Icon_Logo_00005"] = 6,
    ["Icon_Logo_00006"] = 7,
    ["Icon_Logo_00007"] = 8,
    ["Icon_Logo_00008"] = 9,
    ["Icon_Logo_00009"] = 10,
    ["Icon_Logo_00010"] = 11,
    ["Icon_Logo_00011"] = 12,
    ["Icon_Logo_00012"] = 13,
    ["Icon_Logo_00013"] = 14,
    ["Icon_Logo_00014"] = 15,
    ["Icon_Logo_00015"] = 16,
    ["Icon_Logo_00016"] = 17,
    ["Icon_Logo_00017"] = 18,
    ["Icon_Logo_00018"] = 19,
    ["Icon_Logo_00019"] = 20,
    ["Icon_Logo_00020"] = 21,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
