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
            x=4,
            y=4,
            width=300,
            height=300,

        },
        {
            -- a_ghostly
            x=4,
            y=308,
            width=300,
            height=300,

        },
        {
            -- b_ghostly
            x=4,
            y=612,
            width=300,
            height=300,

        },
        {
            -- c_ghostly
            x=308,
            y=4,
            width=300,
            height=300,

        },
        {
            -- d_ghostly
            x=308,
            y=308,
            width=300,
            height=300,

        },
        {
            -- e_ghostly
            x=308,
            y=612,
            width=300,
            height=300,

        },
        {
            -- f_ghostly
            x=612,
            y=4,
            width=300,
            height=300,

        },
        {
            -- g_ghostly
            x=612,
            y=308,
            width=300,
            height=300,

        },
        {
            -- h_ghostly
            x=612,
            y=612,
            width=300,
            height=300,

        },
        {
            -- i_ghostly
            x=916,
            y=4,
            width=300,
            height=300,

        },
        {
            -- j_ghostly
            x=916,
            y=308,
            width=300,
            height=300,

        },
        {
            -- k_ghostly
            x=916,
            y=612,
            width=300,
            height=300,

        },
        {
            -- l_ghostly
            x=1220,
            y=4,
            width=300,
            height=300,

        },
        {
            -- m_ghostly
            x=1220,
            y=308,
            width=300,
            height=300,

        },
        {
            -- n_ghostly
            x=1220,
            y=612,
            width=300,
            height=300,

        },
        {
            -- o_ghostly
            x=1524,
            y=4,
            width=300,
            height=300,

        },
        {
            -- p_ghostly
            x=1524,
            y=308,
            width=300,
            height=300,

        },
        {
            -- q_ghostly
            x=1524,
            y=612,
            width=300,
            height=300,

        },
        {
            -- r_ghostly
            x=1828,
            y=4,
            width=300,
            height=300,

        },
        {
            -- s_ghostly
            x=1828,
            y=308,
            width=300,
            height=300,

        },
        {
            -- t_ghostly
            x=1828,
            y=612,
            width=300,
            height=300,

        },
        {
            -- u_ghostly
            x=2132,
            y=4,
            width=300,
            height=300,

        },
        {
            -- v_ghostly
            x=2436,
            y=4,
            width=300,
            height=300,

        },
        {
            -- w_ghostly
            x=2132,
            y=308,
            width=300,
            height=300,

        },
        {
            -- x_ghostly
            x=2132,
            y=612,
            width=300,
            height=300,

        },
        {
            -- y_ghostly
            x=2436,
            y=308,
            width=300,
            height=300,

        },
        {
            -- z_ghostly
            x=2436,
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
