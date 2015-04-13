--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:51934eaeed896070f39806d04fc3fef7:778573583bbdce3d600ad106a3dc5d3f:ec1574392e83d263b3655f832638f806$
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
            -- a_stone
            x=4,
            y=4,
            width=84,
            height=84,

        },
        {
            -- b_stone
            x=92,
            y=4,
            width=84,
            height=84,

        },
        {
            -- c_stone
            x=179,
            y=4,
            width=84,
            height=84,

        },
        {
            -- d_stone
            x=267,
            y=4,
            width=84,
            height=84,

        },
        {
            -- e_stone
            x=354,
            y=4,
            width=84,
            height=84,

        },
        {
            -- f_stone
            x=442,
            y=4,
            width=84,
            height=84,

        },
        {
            -- g_stone
            x=529,
            y=4,
            width=84,
            height=84,

        },
        {
            -- h_stone
            x=617,
            y=4,
            width=84,
            height=84,

        },
        {
            -- i_stone
            x=704,
            y=4,
            width=84,
            height=84,

        },
        {
            -- j_stone
            x=4,
            y=92,
            width=84,
            height=84,

        },
        {
            -- k_stone
            x=92,
            y=92,
            width=84,
            height=84,

        },
        {
            -- l_stone
            x=179,
            y=92,
            width=84,
            height=84,

        },
        {
            -- m_stone
            x=267,
            y=92,
            width=84,
            height=84,

        },
        {
            -- n_stone
            x=354,
            y=92,
            width=84,
            height=84,

        },
        {
            -- o_stone
            x=442,
            y=92,
            width=84,
            height=84,

        },
        {
            -- p_stone
            x=529,
            y=92,
            width=84,
            height=84,

        },
        {
            -- q_stone
            x=617,
            y=92,
            width=84,
            height=84,

        },
        {
            -- r_stone
            x=704,
            y=92,
            width=84,
            height=84,

        },
        {
            -- s_stone
            x=4,
            y=179,
            width=84,
            height=84,

        },
        {
            -- t_stone
            x=92,
            y=179,
            width=84,
            height=84,

        },
        {
            -- u_stone
            x=179,
            y=179,
            width=84,
            height=84,

        },
        {
            -- v_stone
            x=267,
            y=179,
            width=84,
            height=84,

        },
        {
            -- w_stone
            x=354,
            y=179,
            width=84,
            height=84,

        },
        {
            -- x_stone
            x=442,
            y=179,
            width=84,
            height=84,

        },
        {
            -- y_stone
            x=529,
            y=179,
            width=84,
            height=84,

        },
        {
            -- z_stone
            x=617,
            y=179,
            width=84,
            height=84,

        },
    },
    
    sheetContentWidth = 792,
    sheetContentHeight = 267
}

SheetInfo.frameIndex =
{

    ["a_stone"] = 1,
    ["b_stone"] = 2,
    ["c_stone"] = 3,
    ["d_stone"] = 4,
    ["e_stone"] = 5,
    ["f_stone"] = 6,
    ["g_stone"] = 7,
    ["h_stone"] = 8,
    ["i_stone"] = 9,
    ["j_stone"] = 10,
    ["k_stone"] = 11,
    ["l_stone"] = 12,
    ["m_stone"] = 13,
    ["n_stone"] = 14,
    ["o_stone"] = 15,
    ["p_stone"] = 16,
    ["q_stone"] = 17,
    ["r_stone"] = 18,
    ["s_stone"] = 19,
    ["t_stone"] = 20,
    ["u_stone"] = 21,
    ["v_stone"] = 22,
    ["w_stone"] = 23,
    ["x_stone"] = 24,
    ["y_stone"] = 25,
    ["z_stone"] = 26,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
