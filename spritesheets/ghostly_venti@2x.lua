--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:aa040c4bb7ca8c262048f4601cd63910:68001692d55c503e8a747627cc49681f:8924fb542fea7d803ea205f3a0e94df6$
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
            x=6,
            y=6,
            width=115,
            height=115,

        },
        {
            -- a_ghostly
            x=6,
            y=127,
            width=115,
            height=115,

        },
        {
            -- b_ghostly
            x=6,
            y=248,
            width=115,
            height=115,

        },
        {
            -- c_ghostly
            x=127,
            y=6,
            width=115,
            height=115,

        },
        {
            -- d_ghostly
            x=127,
            y=127,
            width=115,
            height=115,

        },
        {
            -- e_ghostly
            x=127,
            y=248,
            width=115,
            height=115,

        },
        {
            -- f_ghostly
            x=248,
            y=6,
            width=115,
            height=115,

        },
        {
            -- g_ghostly
            x=248,
            y=127,
            width=115,
            height=115,

        },
        {
            -- h_ghostly
            x=248,
            y=248,
            width=115,
            height=115,

        },
        {
            -- i_ghostly
            x=369,
            y=6,
            width=115,
            height=115,

        },
        {
            -- j_ghostly
            x=369,
            y=127,
            width=115,
            height=115,

        },
        {
            -- k_ghostly
            x=369,
            y=248,
            width=115,
            height=115,

        },
        {
            -- l_ghostly
            x=490,
            y=6,
            width=115,
            height=115,

        },
        {
            -- m_ghostly
            x=490,
            y=127,
            width=115,
            height=115,

        },
        {
            -- n_ghostly
            x=490,
            y=248,
            width=115,
            height=115,

        },
        {
            -- o_ghostly
            x=611,
            y=6,
            width=115,
            height=115,

        },
        {
            -- p_ghostly
            x=611,
            y=127,
            width=115,
            height=115,

        },
        {
            -- q_ghostly
            x=611,
            y=248,
            width=115,
            height=115,

        },
        {
            -- r_ghostly
            x=732,
            y=6,
            width=115,
            height=115,

        },
        {
            -- s_ghostly
            x=732,
            y=127,
            width=115,
            height=115,

        },
        {
            -- t_ghostly
            x=732,
            y=248,
            width=115,
            height=115,

        },
        {
            -- u_ghostly
            x=853,
            y=6,
            width=115,
            height=115,

        },
        {
            -- v_ghostly
            x=974,
            y=6,
            width=115,
            height=115,

        },
        {
            -- w_ghostly
            x=853,
            y=127,
            width=115,
            height=115,

        },
        {
            -- x_ghostly
            x=853,
            y=248,
            width=115,
            height=115,

        },
        {
            -- y_ghostly
            x=974,
            y=127,
            width=115,
            height=115,

        },
        {
            -- z_ghostly
            x=974,
            y=248,
            width=115,
            height=115,

        },
    },
    
    sheetContentWidth = 1095,
    sheetContentHeight = 369
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
