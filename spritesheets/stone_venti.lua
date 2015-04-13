--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:eb7b24c8910b74488bda32766c250c53:778573583bbdce3d600ad106a3dc5d3f:927b2838acbe71d65699c9987384f644$
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
            x=3,
            y=3,
            width=58,
            height=58,

        },
        {
            -- b_stone
            x=64,
            y=3,
            width=58,
            height=58,

        },
        {
            -- c_stone
            x=124,
            y=3,
            width=58,
            height=58,

        },
        {
            -- d_stone
            x=185,
            y=3,
            width=58,
            height=58,

        },
        {
            -- e_stone
            x=245,
            y=3,
            width=58,
            height=58,

        },
        {
            -- f_stone
            x=306,
            y=3,
            width=58,
            height=58,

        },
        {
            -- g_stone
            x=366,
            y=3,
            width=58,
            height=58,

        },
        {
            -- h_stone
            x=427,
            y=3,
            width=58,
            height=58,

        },
        {
            -- i_stone
            x=487,
            y=3,
            width=58,
            height=58,

        },
        {
            -- j_stone
            x=3,
            y=64,
            width=58,
            height=58,

        },
        {
            -- k_stone
            x=64,
            y=64,
            width=58,
            height=58,

        },
        {
            -- l_stone
            x=124,
            y=64,
            width=58,
            height=58,

        },
        {
            -- m_stone
            x=185,
            y=64,
            width=58,
            height=58,

        },
        {
            -- n_stone
            x=245,
            y=64,
            width=58,
            height=58,

        },
        {
            -- o_stone
            x=306,
            y=64,
            width=58,
            height=58,

        },
        {
            -- p_stone
            x=366,
            y=64,
            width=58,
            height=58,

        },
        {
            -- q_stone
            x=427,
            y=64,
            width=58,
            height=58,

        },
        {
            -- r_stone
            x=487,
            y=64,
            width=58,
            height=58,

        },
        {
            -- s_stone
            x=3,
            y=124,
            width=58,
            height=58,

        },
        {
            -- t_stone
            x=64,
            y=124,
            width=58,
            height=58,

        },
        {
            -- u_stone
            x=124,
            y=124,
            width=58,
            height=58,

        },
        {
            -- v_stone
            x=185,
            y=124,
            width=58,
            height=58,

        },
        {
            -- w_stone
            x=245,
            y=124,
            width=58,
            height=58,

        },
        {
            -- x_stone
            x=306,
            y=124,
            width=58,
            height=58,

        },
        {
            -- y_stone
            x=366,
            y=124,
            width=58,
            height=58,

        },
        {
            -- z_stone
            x=427,
            y=124,
            width=58,
            height=58,

        },
    },
    
    sheetContentWidth = 548,
    sheetContentHeight = 185
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
