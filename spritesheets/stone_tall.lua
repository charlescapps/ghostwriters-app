--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:345a3d8f9fb1be24c468f1267da9df64:778573583bbdce3d600ad106a3dc5d3f:d679d9eb25c57d35247cced2aedab3e5$
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
            x=2,
            y=2,
            width=150,
            height=150,

        },
        {
            -- b_stone
            x=154,
            y=2,
            width=150,
            height=150,

        },
        {
            -- c_stone
            x=306,
            y=2,
            width=150,
            height=150,

        },
        {
            -- d_stone
            x=458,
            y=2,
            width=150,
            height=150,

        },
        {
            -- e_stone
            x=610,
            y=2,
            width=150,
            height=150,

        },
        {
            -- f_stone
            x=762,
            y=2,
            width=150,
            height=150,

        },
        {
            -- g_stone
            x=914,
            y=2,
            width=150,
            height=150,

        },
        {
            -- h_stone
            x=1066,
            y=2,
            width=150,
            height=150,

        },
        {
            -- i_stone
            x=1218,
            y=2,
            width=150,
            height=150,

        },
        {
            -- j_stone
            x=2,
            y=154,
            width=150,
            height=150,

        },
        {
            -- k_stone
            x=154,
            y=154,
            width=150,
            height=150,

        },
        {
            -- l_stone
            x=306,
            y=154,
            width=150,
            height=150,

        },
        {
            -- m_stone
            x=458,
            y=154,
            width=150,
            height=150,

        },
        {
            -- n_stone
            x=610,
            y=154,
            width=150,
            height=150,

        },
        {
            -- o_stone
            x=762,
            y=154,
            width=150,
            height=150,

        },
        {
            -- p_stone
            x=914,
            y=154,
            width=150,
            height=150,

        },
        {
            -- q_stone
            x=1066,
            y=154,
            width=150,
            height=150,

        },
        {
            -- r_stone
            x=1218,
            y=154,
            width=150,
            height=150,

        },
        {
            -- s_stone
            x=2,
            y=306,
            width=150,
            height=150,

        },
        {
            -- t_stone
            x=154,
            y=306,
            width=150,
            height=150,

        },
        {
            -- u_stone
            x=306,
            y=306,
            width=150,
            height=150,

        },
        {
            -- v_stone
            x=458,
            y=306,
            width=150,
            height=150,

        },
        {
            -- w_stone
            x=610,
            y=306,
            width=150,
            height=150,

        },
        {
            -- x_stone
            x=762,
            y=306,
            width=150,
            height=150,

        },
        {
            -- y_stone
            x=914,
            y=306,
            width=150,
            height=150,

        },
        {
            -- z_stone
            x=1066,
            y=306,
            width=150,
            height=150,

        },
    },
    
    sheetContentWidth = 1370,
    sheetContentHeight = 458
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
