--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:2963126566b4ab607b0eb9e156a6e29e:7a6bda7559ff839ec990f04773b6f345:ae2a36a119b30f64cb62d5c986da33a6$
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
            width=84,
            height=84,

        },
        {
            -- b_ghostly
            x=92,
            y=4,
            width=84,
            height=84,

        },
        {
            -- c_ghostly
            x=179,
            y=4,
            width=84,
            height=84,

        },
        {
            -- d_ghostly
            x=267,
            y=4,
            width=84,
            height=84,

        },
        {
            -- e_ghostly
            x=354,
            y=4,
            width=84,
            height=84,

        },
        {
            -- f_ghostly
            x=442,
            y=4,
            width=84,
            height=84,

        },
        {
            -- g_ghostly
            x=529,
            y=4,
            width=84,
            height=84,

        },
        {
            -- h_ghostly
            x=617,
            y=4,
            width=84,
            height=84,

        },
        {
            -- i_ghostly
            x=704,
            y=4,
            width=84,
            height=84,

        },
        {
            -- j_ghostly
            x=4,
            y=92,
            width=84,
            height=84,

        },
        {
            -- k_ghostly
            x=92,
            y=92,
            width=84,
            height=84,

        },
        {
            -- l_ghostly
            x=179,
            y=92,
            width=84,
            height=84,

        },
        {
            -- m_ghostly
            x=267,
            y=92,
            width=84,
            height=84,

        },
        {
            -- n_ghostly
            x=354,
            y=92,
            width=84,
            height=84,

        },
        {
            -- o_ghostly
            x=442,
            y=92,
            width=84,
            height=84,

        },
        {
            -- p_ghostly
            x=529,
            y=92,
            width=84,
            height=84,

        },
        {
            -- q_ghostly
            x=617,
            y=92,
            width=84,
            height=84,

        },
        {
            -- r_ghostly
            x=704,
            y=92,
            width=84,
            height=84,

        },
        {
            -- s_ghostly
            x=4,
            y=179,
            width=84,
            height=84,

        },
        {
            -- t_ghostly
            x=92,
            y=179,
            width=84,
            height=84,

        },
        {
            -- u_ghostly
            x=179,
            y=179,
            width=84,
            height=84,

        },
        {
            -- v_ghostly
            x=267,
            y=179,
            width=84,
            height=84,

        },
        {
            -- w_ghostly
            x=354,
            y=179,
            width=84,
            height=84,

        },
        {
            -- x_ghostly
            x=442,
            y=179,
            width=84,
            height=84,

        },
        {
            -- y_ghostly
            x=529,
            y=179,
            width=84,
            height=84,

        },
        {
            -- z_ghostly
            x=617,
            y=179,
            width=84,
            height=84,

        },
    },
    
    sheetContentWidth = 792,
    sheetContentHeight = 267
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
