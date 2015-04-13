--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:4012f30e36b076046dcaa51566732637:7a6bda7559ff839ec990f04773b6f345:528b2233b899704b49b580032def7322$
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
            width=150,
            height=150,

        },
        {
            -- b_ghostly
            x=154,
            y=2,
            width=150,
            height=150,

        },
        {
            -- c_ghostly
            x=306,
            y=2,
            width=150,
            height=150,

        },
        {
            -- d_ghostly
            x=458,
            y=2,
            width=150,
            height=150,

        },
        {
            -- e_ghostly
            x=610,
            y=2,
            width=150,
            height=150,

        },
        {
            -- f_ghostly
            x=762,
            y=2,
            width=150,
            height=150,

        },
        {
            -- g_ghostly
            x=914,
            y=2,
            width=150,
            height=150,

        },
        {
            -- h_ghostly
            x=1066,
            y=2,
            width=150,
            height=150,

        },
        {
            -- i_ghostly
            x=1218,
            y=2,
            width=150,
            height=150,

        },
        {
            -- j_ghostly
            x=2,
            y=154,
            width=150,
            height=150,

        },
        {
            -- k_ghostly
            x=154,
            y=154,
            width=150,
            height=150,

        },
        {
            -- l_ghostly
            x=306,
            y=154,
            width=150,
            height=150,

        },
        {
            -- m_ghostly
            x=458,
            y=154,
            width=150,
            height=150,

        },
        {
            -- n_ghostly
            x=610,
            y=154,
            width=150,
            height=150,

        },
        {
            -- o_ghostly
            x=762,
            y=154,
            width=150,
            height=150,

        },
        {
            -- p_ghostly
            x=914,
            y=154,
            width=150,
            height=150,

        },
        {
            -- q_ghostly
            x=1066,
            y=154,
            width=150,
            height=150,

        },
        {
            -- r_ghostly
            x=1218,
            y=154,
            width=150,
            height=150,

        },
        {
            -- s_ghostly
            x=2,
            y=306,
            width=150,
            height=150,

        },
        {
            -- t_ghostly
            x=154,
            y=306,
            width=150,
            height=150,

        },
        {
            -- u_ghostly
            x=306,
            y=306,
            width=150,
            height=150,

        },
        {
            -- v_ghostly
            x=458,
            y=306,
            width=150,
            height=150,

        },
        {
            -- w_ghostly
            x=610,
            y=306,
            width=150,
            height=150,

        },
        {
            -- x_ghostly
            x=762,
            y=306,
            width=150,
            height=150,

        },
        {
            -- y_ghostly
            x=914,
            y=306,
            width=150,
            height=150,

        },
        {
            -- z_ghostly
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
