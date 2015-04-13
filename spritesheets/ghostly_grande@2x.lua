--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:87e6e57e6618a71f813609f050aa8aed:29cc66e1fb59b0225f1c207961215dac:ae2a36a119b30f64cb62d5c986da33a6$
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
            x=4,
            y=4,
            width=167,
            height=167,

        },
        {
            -- b_ghostly
            x=175,
            y=4,
            width=167,
            height=167,

        },
        {
            -- c_ghostly
            x=346,
            y=4,
            width=167,
            height=167,

        },
        {
            -- d_ghostly
            x=517,
            y=4,
            width=167,
            height=167,

        },
        {
            -- e_ghostly
            x=688,
            y=4,
            width=167,
            height=167,

        },
        {
            -- f_ghostly
            x=859,
            y=4,
            width=167,
            height=167,

        },
        {
            -- g_ghostly
            x=1030,
            y=4,
            width=167,
            height=167,

        },
        {
            -- h_ghostly
            x=1201,
            y=4,
            width=167,
            height=167,

        },
        {
            -- i_ghostly
            x=1372,
            y=4,
            width=167,
            height=167,

        },
        {
            -- j_ghostly
            x=4,
            y=175,
            width=167,
            height=167,

        },
        {
            -- k_ghostly
            x=175,
            y=175,
            width=167,
            height=167,

        },
        {
            -- l_ghostly
            x=346,
            y=175,
            width=167,
            height=167,

        },
        {
            -- m_ghostly
            x=517,
            y=175,
            width=167,
            height=167,

        },
        {
            -- n_ghostly
            x=688,
            y=175,
            width=167,
            height=167,

        },
        {
            -- o_ghostly
            x=859,
            y=175,
            width=167,
            height=167,

        },
        {
            -- p_ghostly
            x=1030,
            y=175,
            width=167,
            height=167,

        },
        {
            -- q_ghostly
            x=1201,
            y=175,
            width=167,
            height=167,

        },
        {
            -- r_ghostly
            x=1372,
            y=175,
            width=167,
            height=167,

        },
        {
            -- s_ghostly
            x=4,
            y=346,
            width=167,
            height=167,

        },
        {
            -- t_ghostly
            x=175,
            y=346,
            width=167,
            height=167,

        },
        {
            -- u_ghostly
            x=346,
            y=346,
            width=167,
            height=167,

        },
        {
            -- v_ghostly
            x=517,
            y=346,
            width=167,
            height=167,

        },
        {
            -- w_ghostly
            x=688,
            y=346,
            width=167,
            height=167,

        },
        {
            -- x_ghostly
            x=859,
            y=346,
            width=167,
            height=167,

        },
        {
            -- y_ghostly
            x=1030,
            y=346,
            width=167,
            height=167,

        },
        {
            -- z_ghostly
            x=1201,
            y=346,
            width=167,
            height=167,

        },
    },
    
    sheetContentWidth = 1543,
    sheetContentHeight = 517
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
