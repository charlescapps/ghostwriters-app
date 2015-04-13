--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:3d8fffde0ac751d4144ba5742fe78695:7a6bda7559ff839ec990f04773b6f345:8924fb542fea7d803ea205f3a0e94df6$
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
            x=3,
            y=3,
            width=58,
            height=58,

        },
        {
            -- b_ghostly
            x=64,
            y=3,
            width=58,
            height=58,

        },
        {
            -- c_ghostly
            x=124,
            y=3,
            width=58,
            height=58,

        },
        {
            -- d_ghostly
            x=185,
            y=3,
            width=58,
            height=58,

        },
        {
            -- e_ghostly
            x=245,
            y=3,
            width=58,
            height=58,

        },
        {
            -- f_ghostly
            x=306,
            y=3,
            width=58,
            height=58,

        },
        {
            -- g_ghostly
            x=366,
            y=3,
            width=58,
            height=58,

        },
        {
            -- h_ghostly
            x=427,
            y=3,
            width=58,
            height=58,

        },
        {
            -- i_ghostly
            x=487,
            y=3,
            width=58,
            height=58,

        },
        {
            -- j_ghostly
            x=3,
            y=64,
            width=58,
            height=58,

        },
        {
            -- k_ghostly
            x=64,
            y=64,
            width=58,
            height=58,

        },
        {
            -- l_ghostly
            x=124,
            y=64,
            width=58,
            height=58,

        },
        {
            -- m_ghostly
            x=185,
            y=64,
            width=58,
            height=58,

        },
        {
            -- n_ghostly
            x=245,
            y=64,
            width=58,
            height=58,

        },
        {
            -- o_ghostly
            x=306,
            y=64,
            width=58,
            height=58,

        },
        {
            -- p_ghostly
            x=366,
            y=64,
            width=58,
            height=58,

        },
        {
            -- q_ghostly
            x=427,
            y=64,
            width=58,
            height=58,

        },
        {
            -- r_ghostly
            x=487,
            y=64,
            width=58,
            height=58,

        },
        {
            -- s_ghostly
            x=3,
            y=124,
            width=58,
            height=58,

        },
        {
            -- t_ghostly
            x=64,
            y=124,
            width=58,
            height=58,

        },
        {
            -- u_ghostly
            x=124,
            y=124,
            width=58,
            height=58,

        },
        {
            -- v_ghostly
            x=185,
            y=124,
            width=58,
            height=58,

        },
        {
            -- w_ghostly
            x=245,
            y=124,
            width=58,
            height=58,

        },
        {
            -- x_ghostly
            x=306,
            y=124,
            width=58,
            height=58,

        },
        {
            -- y_ghostly
            x=366,
            y=124,
            width=58,
            height=58,

        },
        {
            -- z_ghostly
            x=427,
            y=124,
            width=58,
            height=58,

        },
    },
    
    sheetContentWidth = 548,
    sheetContentHeight = 185
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
