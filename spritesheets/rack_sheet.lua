--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:bccd8f73d6153d5fa421c0d28d6461af:91819ce3d06c998e6e5072a2a2678609:d2a112ae8c79eb284d2d03fc5d1c95c6$
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
            -- ?_rack
            x=2,
            y=2,
            width=150,
            height=150,

        },
        {
            -- a_rack
            x=2,
            y=154,
            width=150,
            height=150,

        },
        {
            -- b_rack
            x=2,
            y=306,
            width=150,
            height=150,

        },
        {
            -- c_rack
            x=2,
            y=458,
            width=150,
            height=150,

        },
        {
            -- d_rack
            x=2,
            y=610,
            width=150,
            height=150,

        },
        {
            -- e_rack
            x=154,
            y=2,
            width=150,
            height=150,

        },
        {
            -- f_rack
            x=154,
            y=154,
            width=150,
            height=150,

        },
        {
            -- g_rack
            x=154,
            y=306,
            width=150,
            height=150,

        },
        {
            -- h_rack
            x=154,
            y=458,
            width=150,
            height=150,

        },
        {
            -- i_rack
            x=154,
            y=610,
            width=150,
            height=150,

        },
        {
            -- j_rack
            x=306,
            y=2,
            width=150,
            height=150,

        },
        {
            -- k_rack
            x=458,
            y=2,
            width=150,
            height=150,

        },
        {
            -- l_rack
            x=610,
            y=2,
            width=150,
            height=150,

        },
        {
            -- m_rack
            x=762,
            y=2,
            width=150,
            height=150,

        },
        {
            -- n_rack
            x=306,
            y=154,
            width=150,
            height=150,

        },
        {
            -- o_rack
            x=306,
            y=306,
            width=150,
            height=150,

        },
        {
            -- p_rack
            x=306,
            y=458,
            width=150,
            height=150,

        },
        {
            -- q_rack
            x=306,
            y=610,
            width=150,
            height=150,

        },
        {
            -- r_rack
            x=458,
            y=154,
            width=150,
            height=150,

        },
        {
            -- s_rack
            x=610,
            y=154,
            width=150,
            height=150,

        },
        {
            -- scry_rack
            x=762,
            y=154,
            width=150,
            height=150,

        },
        {
            -- t_rack
            x=458,
            y=306,
            width=150,
            height=150,

        },
        {
            -- u_rack
            x=458,
            y=458,
            width=150,
            height=150,

        },
        {
            -- v_rack
            x=458,
            y=610,
            width=150,
            height=150,

        },
        {
            -- w_rack
            x=610,
            y=306,
            width=150,
            height=150,

        },
        {
            -- x_rack
            x=762,
            y=306,
            width=150,
            height=150,

        },
        {
            -- y_rack
            x=610,
            y=458,
            width=150,
            height=150,

        },
        {
            -- z_rack
            x=610,
            y=610,
            width=150,
            height=150,

        },
    },
    
    sheetContentWidth = 914,
    sheetContentHeight = 762
}

SheetInfo.frameIndex =
{

    ["?_rack"] = 1,
    ["a_rack"] = 2,
    ["b_rack"] = 3,
    ["c_rack"] = 4,
    ["d_rack"] = 5,
    ["e_rack"] = 6,
    ["f_rack"] = 7,
    ["g_rack"] = 8,
    ["h_rack"] = 9,
    ["i_rack"] = 10,
    ["j_rack"] = 11,
    ["k_rack"] = 12,
    ["l_rack"] = 13,
    ["m_rack"] = 14,
    ["n_rack"] = 15,
    ["o_rack"] = 16,
    ["p_rack"] = 17,
    ["q_rack"] = 18,
    ["r_rack"] = 19,
    ["s_rack"] = 20,
    ["scry_rack"] = 21,
    ["t_rack"] = 22,
    ["u_rack"] = 23,
    ["v_rack"] = 24,
    ["w_rack"] = 25,
    ["x_rack"] = 26,
    ["y_rack"] = 27,
    ["z_rack"] = 28,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
