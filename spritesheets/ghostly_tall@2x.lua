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
            x=4,
            y=4,
            width=300,
            height=300,

        },
        {
            -- b_ghostly
            x=308,
            y=4,
            width=300,
            height=300,

        },
        {
            -- c_ghostly
            x=612,
            y=4,
            width=300,
            height=300,

        },
        {
            -- d_ghostly
            x=916,
            y=4,
            width=300,
            height=300,

        },
        {
            -- e_ghostly
            x=1220,
            y=4,
            width=300,
            height=300,

        },
        {
            -- f_ghostly
            x=1524,
            y=4,
            width=300,
            height=300,

        },
        {
            -- g_ghostly
            x=1828,
            y=4,
            width=300,
            height=300,

        },
        {
            -- h_ghostly
            x=2132,
            y=4,
            width=300,
            height=300,

        },
        {
            -- i_ghostly
            x=2436,
            y=4,
            width=300,
            height=300,

        },
        {
            -- j_ghostly
            x=4,
            y=308,
            width=300,
            height=300,

        },
        {
            -- k_ghostly
            x=308,
            y=308,
            width=300,
            height=300,

        },
        {
            -- l_ghostly
            x=612,
            y=308,
            width=300,
            height=300,

        },
        {
            -- m_ghostly
            x=916,
            y=308,
            width=300,
            height=300,

        },
        {
            -- n_ghostly
            x=1220,
            y=308,
            width=300,
            height=300,

        },
        {
            -- o_ghostly
            x=1524,
            y=308,
            width=300,
            height=300,

        },
        {
            -- p_ghostly
            x=1828,
            y=308,
            width=300,
            height=300,

        },
        {
            -- q_ghostly
            x=2132,
            y=308,
            width=300,
            height=300,

        },
        {
            -- r_ghostly
            x=2436,
            y=308,
            width=300,
            height=300,

        },
        {
            -- s_ghostly
            x=4,
            y=612,
            width=300,
            height=300,

        },
        {
            -- t_ghostly
            x=308,
            y=612,
            width=300,
            height=300,

        },
        {
            -- u_ghostly
            x=612,
            y=612,
            width=300,
            height=300,

        },
        {
            -- v_ghostly
            x=916,
            y=612,
            width=300,
            height=300,

        },
        {
            -- w_ghostly
            x=1220,
            y=612,
            width=300,
            height=300,

        },
        {
            -- x_ghostly
            x=1524,
            y=612,
            width=300,
            height=300,

        },
        {
            -- y_ghostly
            x=1828,
            y=612,
            width=300,
            height=300,

        },
        {
            -- z_ghostly
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
