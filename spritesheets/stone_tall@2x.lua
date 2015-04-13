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
            x=4,
            y=4,
            width=300,
            height=300,

        },
        {
            -- b_stone
            x=308,
            y=4,
            width=300,
            height=300,

        },
        {
            -- c_stone
            x=612,
            y=4,
            width=300,
            height=300,

        },
        {
            -- d_stone
            x=916,
            y=4,
            width=300,
            height=300,

        },
        {
            -- e_stone
            x=1220,
            y=4,
            width=300,
            height=300,

        },
        {
            -- f_stone
            x=1524,
            y=4,
            width=300,
            height=300,

        },
        {
            -- g_stone
            x=1828,
            y=4,
            width=300,
            height=300,

        },
        {
            -- h_stone
            x=2132,
            y=4,
            width=300,
            height=300,

        },
        {
            -- i_stone
            x=2436,
            y=4,
            width=300,
            height=300,

        },
        {
            -- j_stone
            x=4,
            y=308,
            width=300,
            height=300,

        },
        {
            -- k_stone
            x=308,
            y=308,
            width=300,
            height=300,

        },
        {
            -- l_stone
            x=612,
            y=308,
            width=300,
            height=300,

        },
        {
            -- m_stone
            x=916,
            y=308,
            width=300,
            height=300,

        },
        {
            -- n_stone
            x=1220,
            y=308,
            width=300,
            height=300,

        },
        {
            -- o_stone
            x=1524,
            y=308,
            width=300,
            height=300,

        },
        {
            -- p_stone
            x=1828,
            y=308,
            width=300,
            height=300,

        },
        {
            -- q_stone
            x=2132,
            y=308,
            width=300,
            height=300,

        },
        {
            -- r_stone
            x=2436,
            y=308,
            width=300,
            height=300,

        },
        {
            -- s_stone
            x=4,
            y=612,
            width=300,
            height=300,

        },
        {
            -- t_stone
            x=308,
            y=612,
            width=300,
            height=300,

        },
        {
            -- u_stone
            x=612,
            y=612,
            width=300,
            height=300,

        },
        {
            -- v_stone
            x=916,
            y=612,
            width=300,
            height=300,

        },
        {
            -- w_stone
            x=1220,
            y=612,
            width=300,
            height=300,

        },
        {
            -- x_stone
            x=1524,
            y=612,
            width=300,
            height=300,

        },
        {
            -- y_stone
            x=1828,
            y=612,
            width=300,
            height=300,

        },
        {
            -- z_stone
            x=2132,
            y=612,
            width=300,
            height=300,

        },
    },
    
    sheetContentWidth = 2740,
    sheetContentHeight = 916
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
