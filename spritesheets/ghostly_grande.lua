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
            x=4,
            y=4,
            width=84,
            height=84,

        },
        {
            -- a_ghostly
            x=4,
            y=92,
            width=84,
            height=84,

        },
        {
            -- b_ghostly
            x=4,
            y=179,
            width=84,
            height=84,

        },
        {
            -- c_ghostly
            x=92,
            y=4,
            width=84,
            height=84,

        },
        {
            -- d_ghostly
            x=92,
            y=92,
            width=84,
            height=84,

        },
        {
            -- e_ghostly
            x=92,
            y=179,
            width=84,
            height=84,

        },
        {
            -- f_ghostly
            x=179,
            y=4,
            width=84,
            height=84,

        },
        {
            -- g_ghostly
            x=179,
            y=92,
            width=84,
            height=84,

        },
        {
            -- h_ghostly
            x=179,
            y=179,
            width=84,
            height=84,

        },
        {
            -- i_ghostly
            x=267,
            y=4,
            width=84,
            height=84,

        },
        {
            -- j_ghostly
            x=267,
            y=92,
            width=84,
            height=84,

        },
        {
            -- k_ghostly
            x=267,
            y=179,
            width=84,
            height=84,

        },
        {
            -- l_ghostly
            x=354,
            y=4,
            width=84,
            height=84,

        },
        {
            -- m_ghostly
            x=354,
            y=92,
            width=84,
            height=84,

        },
        {
            -- n_ghostly
            x=354,
            y=179,
            width=84,
            height=84,

        },
        {
            -- o_ghostly
            x=442,
            y=4,
            width=84,
            height=84,

        },
        {
            -- p_ghostly
            x=442,
            y=92,
            width=84,
            height=84,

        },
        {
            -- q_ghostly
            x=442,
            y=179,
            width=84,
            height=84,

        },
        {
            -- r_ghostly
            x=529,
            y=4,
            width=84,
            height=84,

        },
        {
            -- s_ghostly
            x=529,
            y=92,
            width=84,
            height=84,

        },
        {
            -- t_ghostly
            x=529,
            y=179,
            width=84,
            height=84,

        },
        {
            -- u_ghostly
            x=617,
            y=4,
            width=84,
            height=84,

        },
        {
            -- v_ghostly
            x=704,
            y=4,
            width=84,
            height=84,

        },
        {
            -- w_ghostly
            x=617,
            y=92,
            width=84,
            height=84,

        },
        {
            -- x_ghostly
            x=617,
            y=179,
            width=84,
            height=84,

        },
        {
            -- y_ghostly
            x=704,
            y=92,
            width=84,
            height=84,

        },
        {
            -- z_ghostly
            x=704,
            y=179,
            width=84,
            height=84,

        },
    },
    
    sheetContentWidth = 794,
    sheetContentHeight = 267
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
