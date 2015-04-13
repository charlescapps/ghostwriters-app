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
            x=6,
            y=6,
            width=115,
            height=115,

        },
        {
            -- b_stone
            x=127,
            y=6,
            width=115,
            height=115,

        },
        {
            -- c_stone
            x=248,
            y=6,
            width=115,
            height=115,

        },
        {
            -- d_stone
            x=369,
            y=6,
            width=115,
            height=115,

        },
        {
            -- e_stone
            x=490,
            y=6,
            width=115,
            height=115,

        },
        {
            -- f_stone
            x=611,
            y=6,
            width=115,
            height=115,

        },
        {
            -- g_stone
            x=732,
            y=6,
            width=115,
            height=115,

        },
        {
            -- h_stone
            x=853,
            y=6,
            width=115,
            height=115,

        },
        {
            -- i_stone
            x=974,
            y=6,
            width=115,
            height=115,

        },
        {
            -- j_stone
            x=6,
            y=127,
            width=115,
            height=115,

        },
        {
            -- k_stone
            x=127,
            y=127,
            width=115,
            height=115,

        },
        {
            -- l_stone
            x=248,
            y=127,
            width=115,
            height=115,

        },
        {
            -- m_stone
            x=369,
            y=127,
            width=115,
            height=115,

        },
        {
            -- n_stone
            x=490,
            y=127,
            width=115,
            height=115,

        },
        {
            -- o_stone
            x=611,
            y=127,
            width=115,
            height=115,

        },
        {
            -- p_stone
            x=732,
            y=127,
            width=115,
            height=115,

        },
        {
            -- q_stone
            x=853,
            y=127,
            width=115,
            height=115,

        },
        {
            -- r_stone
            x=974,
            y=127,
            width=115,
            height=115,

        },
        {
            -- s_stone
            x=6,
            y=248,
            width=115,
            height=115,

        },
        {
            -- t_stone
            x=127,
            y=248,
            width=115,
            height=115,

        },
        {
            -- u_stone
            x=248,
            y=248,
            width=115,
            height=115,

        },
        {
            -- v_stone
            x=369,
            y=248,
            width=115,
            height=115,

        },
        {
            -- w_stone
            x=490,
            y=248,
            width=115,
            height=115,

        },
        {
            -- x_stone
            x=611,
            y=248,
            width=115,
            height=115,

        },
        {
            -- y_stone
            x=732,
            y=248,
            width=115,
            height=115,

        },
        {
            -- z_stone
            x=853,
            y=248,
            width=115,
            height=115,

        },
    },
    
    sheetContentWidth = 1095,
    sheetContentHeight = 369
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
