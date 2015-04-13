--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:359715eae1295e87a1e6778e0ae41f4c:19b7264a09ae311ad1cf7add3f983e6e:d2a112ae8c79eb284d2d03fc5d1c95c6$
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
            -- a_rack
            x=4,
            y=4,
            width=300,
            height=300,

        },
        {
            -- b_rack
            x=308,
            y=4,
            width=300,
            height=300,

        },
        {
            -- c_rack
            x=612,
            y=4,
            width=300,
            height=300,

        },
        {
            -- d_rack
            x=916,
            y=4,
            width=300,
            height=300,

        },
        {
            -- e_rack
            x=1220,
            y=4,
            width=300,
            height=300,

        },
        {
            -- f_rack
            x=1524,
            y=4,
            width=300,
            height=300,

        },
        {
            -- g_rack
            x=1828,
            y=4,
            width=300,
            height=300,

        },
        {
            -- h_rack
            x=2132,
            y=4,
            width=300,
            height=300,

        },
        {
            -- i_rack
            x=2436,
            y=4,
            width=300,
            height=300,

        },
        {
            -- j_rack
            x=4,
            y=308,
            width=300,
            height=300,

        },
        {
            -- k_rack
            x=308,
            y=308,
            width=300,
            height=300,

        },
        {
            -- l_rack
            x=612,
            y=308,
            width=300,
            height=300,

        },
        {
            -- m_rack
            x=916,
            y=308,
            width=300,
            height=300,

        },
        {
            -- n_rack
            x=1220,
            y=308,
            width=300,
            height=300,

        },
        {
            -- o_rack
            x=1524,
            y=308,
            width=300,
            height=300,

        },
        {
            -- p_rack
            x=1828,
            y=308,
            width=300,
            height=300,

        },
        {
            -- q_rack
            x=2132,
            y=308,
            width=300,
            height=300,

        },
        {
            -- r_rack
            x=2436,
            y=308,
            width=300,
            height=300,

        },
        {
            -- s_rack
            x=4,
            y=612,
            width=300,
            height=300,

        },
        {
            -- t_rack
            x=308,
            y=612,
            width=300,
            height=300,

        },
        {
            -- u_rack
            x=612,
            y=612,
            width=300,
            height=300,

        },
        {
            -- v_rack
            x=916,
            y=612,
            width=300,
            height=300,

        },
        {
            -- w_rack
            x=1220,
            y=612,
            width=300,
            height=300,

        },
        {
            -- x_rack
            x=1524,
            y=612,
            width=300,
            height=300,

        },
        {
            -- y_rack
            x=1828,
            y=612,
            width=300,
            height=300,

        },
        {
            -- z_rack
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

    ["a_rack"] = 1,
    ["b_rack"] = 2,
    ["c_rack"] = 3,
    ["d_rack"] = 4,
    ["e_rack"] = 5,
    ["f_rack"] = 6,
    ["g_rack"] = 7,
    ["h_rack"] = 8,
    ["i_rack"] = 9,
    ["j_rack"] = 10,
    ["k_rack"] = 11,
    ["l_rack"] = 12,
    ["m_rack"] = 13,
    ["n_rack"] = 14,
    ["o_rack"] = 15,
    ["p_rack"] = 16,
    ["q_rack"] = 17,
    ["r_rack"] = 18,
    ["s_rack"] = 19,
    ["t_rack"] = 20,
    ["u_rack"] = 21,
    ["v_rack"] = 22,
    ["w_rack"] = 23,
    ["x_rack"] = 24,
    ["y_rack"] = 25,
    ["z_rack"] = 26,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
