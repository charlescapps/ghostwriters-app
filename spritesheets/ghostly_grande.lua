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
            x=2,
            y=2,
            width=83,
            height=83,

        },
        {
            -- b_ghostly
            x=87,
            y=2,
            width=83,
            height=83,

        },
        {
            -- c_ghostly
            x=173,
            y=2,
            width=83,
            height=83,

        },
        {
            -- d_ghostly
            x=258,
            y=2,
            width=83,
            height=83,

        },
        {
            -- e_ghostly
            x=344,
            y=2,
            width=83,
            height=83,

        },
        {
            -- f_ghostly
            x=429,
            y=2,
            width=83,
            height=83,

        },
        {
            -- g_ghostly
            x=515,
            y=2,
            width=83,
            height=83,

        },
        {
            -- h_ghostly
            x=600,
            y=2,
            width=83,
            height=83,

        },
        {
            -- i_ghostly
            x=686,
            y=2,
            width=83,
            height=83,

        },
        {
            -- j_ghostly
            x=2,
            y=87,
            width=83,
            height=83,

        },
        {
            -- k_ghostly
            x=87,
            y=87,
            width=83,
            height=83,

        },
        {
            -- l_ghostly
            x=173,
            y=87,
            width=83,
            height=83,

        },
        {
            -- m_ghostly
            x=258,
            y=87,
            width=83,
            height=83,

        },
        {
            -- n_ghostly
            x=344,
            y=87,
            width=83,
            height=83,

        },
        {
            -- o_ghostly
            x=429,
            y=87,
            width=83,
            height=83,

        },
        {
            -- p_ghostly
            x=515,
            y=87,
            width=83,
            height=83,

        },
        {
            -- q_ghostly
            x=600,
            y=87,
            width=83,
            height=83,

        },
        {
            -- r_ghostly
            x=686,
            y=87,
            width=83,
            height=83,

        },
        {
            -- s_ghostly
            x=2,
            y=173,
            width=83,
            height=83,

        },
        {
            -- t_ghostly
            x=87,
            y=173,
            width=83,
            height=83,

        },
        {
            -- u_ghostly
            x=173,
            y=173,
            width=83,
            height=83,

        },
        {
            -- v_ghostly
            x=258,
            y=173,
            width=83,
            height=83,

        },
        {
            -- w_ghostly
            x=344,
            y=173,
            width=83,
            height=83,

        },
        {
            -- x_ghostly
            x=429,
            y=173,
            width=83,
            height=83,

        },
        {
            -- y_ghostly
            x=515,
            y=173,
            width=83,
            height=83,

        },
        {
            -- z_ghostly
            x=600,
            y=173,
            width=83,
            height=83,

        },
    },
    
    sheetContentWidth = 771,
    sheetContentHeight = 258
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
