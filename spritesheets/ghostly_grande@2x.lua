--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:2963126566b4ab607b0eb9e156a6e29e:7a6bda7559ff839ec990f04773b6f345:ae2a36a119b30f64cb62d5c986da33a6$
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
            -- a_ghostly
            x=8,
            y=8,
            width=167,
            height=167,

        },
        {
            -- b_ghostly
            x=183,
            y=8,
            width=167,
            height=167,

        },
        {
            -- c_ghostly
            x=358,
            y=8,
            width=167,
            height=167,

        },
        {
            -- d_ghostly
            x=533,
            y=8,
            width=167,
            height=167,

        },
        {
            -- e_ghostly
            x=708,
            y=8,
            width=167,
            height=167,

        },
        {
            -- f_ghostly
            x=883,
            y=8,
            width=167,
            height=167,

        },
        {
            -- g_ghostly
            x=1058,
            y=8,
            width=167,
            height=167,

        },
        {
            -- h_ghostly
            x=1233,
            y=8,
            width=167,
            height=167,

        },
        {
            -- i_ghostly
            x=1408,
            y=8,
            width=167,
            height=167,

        },
        {
            -- j_ghostly
            x=8,
            y=183,
            width=167,
            height=167,

        },
        {
            -- k_ghostly
            x=183,
            y=183,
            width=167,
            height=167,

        },
        {
            -- l_ghostly
            x=358,
            y=183,
            width=167,
            height=167,

        },
        {
            -- m_ghostly
            x=533,
            y=183,
            width=167,
            height=167,

        },
        {
            -- n_ghostly
            x=708,
            y=183,
            width=167,
            height=167,

        },
        {
            -- o_ghostly
            x=883,
            y=183,
            width=167,
            height=167,

        },
        {
            -- p_ghostly
            x=1058,
            y=183,
            width=167,
            height=167,

        },
        {
            -- q_ghostly
            x=1233,
            y=183,
            width=167,
            height=167,

        },
        {
            -- r_ghostly
            x=1408,
            y=183,
            width=167,
            height=167,

        },
        {
            -- s_ghostly
            x=8,
            y=358,
            width=167,
            height=167,

        },
        {
            -- t_ghostly
            x=183,
            y=358,
            width=167,
            height=167,

        },
        {
            -- u_ghostly
            x=358,
            y=358,
            width=167,
            height=167,

        },
        {
            -- v_ghostly
            x=533,
            y=358,
            width=167,
            height=167,

        },
        {
            -- w_ghostly
            x=708,
            y=358,
            width=167,
            height=167,

        },
        {
            -- x_ghostly
            x=883,
            y=358,
            width=167,
            height=167,

        },
        {
            -- y_ghostly
            x=1058,
            y=358,
            width=167,
            height=167,

        },
        {
            -- z_ghostly
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

    ["a_ghostly"] = 1,
    ["b_ghostly"] = 2,
    ["c_ghostly"] = 3,
    ["d_ghostly"] = 4,
    ["e_ghostly"] = 5,
    ["f_ghostly"] = 6,
    ["g_ghostly"] = 7,
    ["h_ghostly"] = 8,
    ["i_ghostly"] = 9,
    ["j_ghostly"] = 10,
    ["k_ghostly"] = 11,
    ["l_ghostly"] = 12,
    ["m_ghostly"] = 13,
    ["n_ghostly"] = 14,
    ["o_ghostly"] = 15,
    ["p_ghostly"] = 16,
    ["q_ghostly"] = 17,
    ["r_ghostly"] = 18,
    ["s_ghostly"] = 19,
    ["t_ghostly"] = 20,
    ["u_ghostly"] = 21,
    ["v_ghostly"] = 22,
    ["w_ghostly"] = 23,
    ["x_ghostly"] = 24,
    ["y_ghostly"] = 25,
    ["z_ghostly"] = 26,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
