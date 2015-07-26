--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:9b11824883d3a3c6444c2f02bf0f89fc:1b422e321e847e3ee83c1a7b6c4420ca:62dbf8b33b72019ae5e806a9f356ac53$
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
            x=2,
            y=2,
            width=150,
            height=150,

        },
        {
            -- b_rack
            x=2,
            y=154,
            width=150,
            height=150,

        },
        {
            -- c_rack
            x=2,
            y=306,
            width=150,
            height=150,

        },
        {
            -- d_rack
            x=154,
            y=2,
            width=150,
            height=150,

        },
        {
            -- e_rack
            x=154,
            y=154,
            width=150,
            height=150,

        },
        {
            -- f_rack
            x=154,
            y=306,
            width=150,
            height=150,

        },
        {
            -- g_rack
            x=306,
            y=2,
            width=150,
            height=150,

        },
        {
            -- h_rack
            x=306,
            y=154,
            width=150,
            height=150,

        },
        {
            -- i_rack
            x=306,
            y=306,
            width=150,
            height=150,

        },
        {
            -- j_rack
            x=458,
            y=2,
            width=150,
            height=150,

        },
        {
            -- k_rack
            x=458,
            y=154,
            width=150,
            height=150,

        },
        {
            -- l_rack
            x=458,
            y=306,
            width=150,
            height=150,

        },
        {
            -- m_rack
            x=610,
            y=2,
            width=150,
            height=150,

        },
        {
            -- n_rack
            x=610,
            y=154,
            width=150,
            height=150,

        },
        {
            -- o_rack
            x=610,
            y=306,
            width=150,
            height=150,

        },
        {
            -- p_rack
            x=762,
            y=2,
            width=150,
            height=150,

        },
        {
            -- q_rack
            x=762,
            y=154,
            width=150,
            height=150,

        },
        {
            -- question_rack
            x=762,
            y=306,
            width=150,
            height=150,

        },
        {
            -- r_rack
            x=914,
            y=2,
            width=150,
            height=150,

        },
        {
            -- s_rack
            x=914,
            y=154,
            width=150,
            height=150,

        },
        {
            -- scry_rack
            x=914,
            y=306,
            width=150,
            height=150,

        },
        {
            -- t_rack
            x=1066,
            y=2,
            width=150,
            height=150,

        },
        {
            -- u_rack
            x=1066,
            y=154,
            width=150,
            height=150,

        },
        {
            -- v_rack
            x=1066,
            y=306,
            width=150,
            height=150,

        },
        {
            -- w_rack
            x=1218,
            y=2,
            width=150,
            height=150,

        },
        {
            -- x_rack
            x=1370,
            y=2,
            width=150,
            height=150,

        },
        {
            -- y_rack
            x=1218,
            y=154,
            width=150,
            height=150,

        },
        {
            -- z_rack
            x=1218,
            y=306,
            width=150,
            height=150,

        },
    },
    
    sheetContentWidth = 1522,
    sheetContentHeight = 458
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
    ["question_rack"] = 18,
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
