--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:acff2ed4e8279427c6761a75325357cd:68001692d55c503e8a747627cc49681f:ae2a36a119b30f64cb62d5c986da33a6$
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
            x=8,
            y=8,
            width=167,
            height=167,

        },
        {
            -- a_ghostly
            x=8,
            y=183,
            width=167,
            height=167,

        },
        {
            -- b_ghostly
            x=8,
            y=358,
            width=167,
            height=167,

        },
        {
            -- c_ghostly
            x=183,
            y=8,
            width=167,
            height=167,

        },
        {
            -- d_ghostly
            x=183,
            y=183,
            width=167,
            height=167,

        },
        {
            -- e_ghostly
            x=183,
            y=358,
            width=167,
            height=167,

        },
        {
            -- f_ghostly
            x=358,
            y=8,
            width=167,
            height=167,

        },
        {
            -- g_ghostly
            x=358,
            y=183,
            width=167,
            height=167,

        },
        {
            -- h_ghostly
            x=358,
            y=358,
            width=167,
            height=167,

        },
        {
            -- i_ghostly
            x=533,
            y=8,
            width=167,
            height=167,

        },
        {
            -- j_ghostly
            x=533,
            y=183,
            width=167,
            height=167,

        },
        {
            -- k_ghostly
            x=533,
            y=358,
            width=167,
            height=167,

        },
        {
            -- l_ghostly
            x=708,
            y=8,
            width=167,
            height=167,

        },
        {
            -- m_ghostly
            x=708,
            y=183,
            width=167,
            height=167,

        },
        {
            -- n_ghostly
            x=708,
            y=358,
            width=167,
            height=167,

        },
        {
            -- o_ghostly
            x=883,
            y=8,
            width=167,
            height=167,

        },
        {
            -- p_ghostly
            x=883,
            y=183,
            width=167,
            height=167,

        },
        {
            -- q_ghostly
            x=883,
            y=358,
            width=167,
            height=167,

        },
        {
            -- r_ghostly
            x=1058,
            y=8,
            width=167,
            height=167,

        },
        {
            -- s_ghostly
            x=1058,
            y=183,
            width=167,
            height=167,

        },
        {
            -- t_ghostly
            x=1058,
            y=358,
            width=167,
            height=167,

        },
        {
            -- u_ghostly
            x=1233,
            y=8,
            width=167,
            height=167,

        },
        {
            -- v_ghostly
            x=1408,
            y=8,
            width=167,
            height=167,

        },
        {
            -- w_ghostly
            x=1233,
            y=183,
            width=167,
            height=167,

        },
        {
            -- x_ghostly
            x=1233,
            y=358,
            width=167,
            height=167,

        },
        {
            -- y_ghostly
            x=1408,
            y=183,
            width=167,
            height=167,

        },
        {
            -- z_ghostly
            x=1408,
            y=358,
            width=167,
            height=167,

        },
    },
    
    sheetContentWidth = 1588,
    sheetContentHeight = 533
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
