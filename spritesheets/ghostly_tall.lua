--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:5010addf6d106a7194a490e12000dae4:68001692d55c503e8a747627cc49681f:528b2233b899704b49b580032def7322$
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
            -- ?_ghostly
            x=2,
            y=2,
            width=150,
            height=150,

        },
        {
            -- a_ghostly
            x=2,
            y=154,
            width=150,
            height=150,

        },
        {
            -- b_ghostly
            x=2,
            y=306,
            width=150,
            height=150,

        },
        {
            -- c_ghostly
            x=154,
            y=2,
            width=150,
            height=150,

        },
        {
            -- d_ghostly
            x=154,
            y=154,
            width=150,
            height=150,

        },
        {
            -- e_ghostly
            x=154,
            y=306,
            width=150,
            height=150,

        },
        {
            -- f_ghostly
            x=306,
            y=2,
            width=150,
            height=150,

        },
        {
            -- g_ghostly
            x=306,
            y=154,
            width=150,
            height=150,

        },
        {
            -- h_ghostly
            x=306,
            y=306,
            width=150,
            height=150,

        },
        {
            -- i_ghostly
            x=458,
            y=2,
            width=150,
            height=150,

        },
        {
            -- j_ghostly
            x=458,
            y=154,
            width=150,
            height=150,

        },
        {
            -- k_ghostly
            x=458,
            y=306,
            width=150,
            height=150,

        },
        {
            -- l_ghostly
            x=610,
            y=2,
            width=150,
            height=150,

        },
        {
            -- m_ghostly
            x=610,
            y=154,
            width=150,
            height=150,

        },
        {
            -- n_ghostly
            x=610,
            y=306,
            width=150,
            height=150,

        },
        {
            -- o_ghostly
            x=762,
            y=2,
            width=150,
            height=150,

        },
        {
            -- p_ghostly
            x=762,
            y=154,
            width=150,
            height=150,

        },
        {
            -- q_ghostly
            x=762,
            y=306,
            width=150,
            height=150,

        },
        {
            -- r_ghostly
            x=914,
            y=2,
            width=150,
            height=150,

        },
        {
            -- s_ghostly
            x=914,
            y=154,
            width=150,
            height=150,

        },
        {
            -- t_ghostly
            x=914,
            y=306,
            width=150,
            height=150,

        },
        {
            -- u_ghostly
            x=1066,
            y=2,
            width=150,
            height=150,

        },
        {
            -- v_ghostly
            x=1218,
            y=2,
            width=150,
            height=150,

        },
        {
            -- w_ghostly
            x=1066,
            y=154,
            width=150,
            height=150,

        },
        {
            -- x_ghostly
            x=1066,
            y=306,
            width=150,
            height=150,

        },
        {
            -- y_ghostly
            x=1218,
            y=154,
            width=150,
            height=150,

        },
        {
            -- z_ghostly
            x=1218,
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

    ["?_ghostly"] = 1,
    ["a_ghostly"] = 2,
    ["b_ghostly"] = 3,
    ["c_ghostly"] = 4,
    ["d_ghostly"] = 5,
    ["e_ghostly"] = 6,
    ["f_ghostly"] = 7,
    ["g_ghostly"] = 8,
    ["h_ghostly"] = 9,
    ["i_ghostly"] = 10,
    ["j_ghostly"] = 11,
    ["k_ghostly"] = 12,
    ["l_ghostly"] = 13,
    ["m_ghostly"] = 14,
    ["n_ghostly"] = 15,
    ["o_ghostly"] = 16,
    ["p_ghostly"] = 17,
    ["q_ghostly"] = 18,
    ["r_ghostly"] = 19,
    ["s_ghostly"] = 20,
    ["t_ghostly"] = 21,
    ["u_ghostly"] = 22,
    ["v_ghostly"] = 23,
    ["w_ghostly"] = 24,
    ["x_ghostly"] = 25,
    ["y_ghostly"] = 26,
    ["z_ghostly"] = 27,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
