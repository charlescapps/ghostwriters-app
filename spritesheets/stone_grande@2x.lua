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
            x=8,
            y=8,
            width=167,
            height=167,

        },
        {
            -- b_stone
            x=183,
            y=8,
            width=167,
            height=167,

        },
        {
            -- c_stone
            x=358,
            y=8,
            width=167,
            height=167,

        },
        {
            -- d_stone
            x=533,
            y=8,
            width=167,
            height=167,

        },
        {
            -- e_stone
            x=708,
            y=8,
            width=167,
            height=167,

        },
        {
            -- f_stone
            x=883,
            y=8,
            width=167,
            height=167,

        },
        {
            -- g_stone
            x=1058,
            y=8,
            width=167,
            height=167,

        },
        {
            -- h_stone
            x=1233,
            y=8,
            width=167,
            height=167,

        },
        {
            -- i_stone
            x=1408,
            y=8,
            width=167,
            height=167,

        },
        {
            -- j_stone
            x=8,
            y=183,
            width=167,
            height=167,

        },
        {
            -- k_stone
            x=183,
            y=183,
            width=167,
            height=167,

        },
        {
            -- l_stone
            x=358,
            y=183,
            width=167,
            height=167,

        },
        {
            -- m_stone
            x=533,
            y=183,
            width=167,
            height=167,

        },
        {
            -- n_stone
            x=708,
            y=183,
            width=167,
            height=167,

        },
        {
            -- o_stone
            x=883,
            y=183,
            width=167,
            height=167,

        },
        {
            -- p_stone
            x=1058,
            y=183,
            width=167,
            height=167,

        },
        {
            -- q_stone
            x=1233,
            y=183,
            width=167,
            height=167,

        },
        {
            -- r_stone
            x=1408,
            y=183,
            width=167,
            height=167,

        },
        {
            -- s_stone
            x=8,
            y=358,
            width=167,
            height=167,

        },
        {
            -- t_stone
            x=183,
            y=358,
            width=167,
            height=167,

        },
        {
            -- u_stone
            x=358,
            y=358,
            width=167,
            height=167,

        },
        {
            -- v_stone
            x=533,
            y=358,
            width=167,
            height=167,

        },
        {
            -- w_stone
            x=708,
            y=358,
            width=167,
            height=167,

        },
        {
            -- x_stone
            x=883,
            y=358,
            width=167,
            height=167,

        },
        {
            -- y_stone
            x=1058,
            y=358,
            width=167,
            height=167,

        },
        {
            -- z_stone
            x=1233,
            y=358,
            width=167,
            height=167,

        },
    },
    
    sheetContentWidth = 1583,
    sheetContentHeight = 533
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
