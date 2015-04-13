--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:cbb0565a891fab908e383931c541c086:29cc66e1fb59b0225f1c207961215dac:8924fb542fea7d803ea205f3a0e94df6$
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
            x=6,
            y=6,
            width=116,
            height=116,

        },
        {
            -- b_ghostly
            x=128,
            y=6,
            width=116,
            height=116,

        },
        {
            -- c_ghostly
            x=250,
            y=6,
            width=116,
            height=116,

        },
        {
            -- d_ghostly
            x=372,
            y=6,
            width=116,
            height=116,

        },
        {
            -- e_ghostly
            x=494,
            y=6,
            width=116,
            height=116,

        },
        {
            -- f_ghostly
            x=616,
            y=6,
            width=116,
            height=116,

        },
        {
            -- g_ghostly
            x=738,
            y=6,
            width=116,
            height=116,

        },
        {
            -- h_ghostly
            x=860,
            y=6,
            width=116,
            height=116,

        },
        {
            -- i_ghostly
            x=982,
            y=6,
            width=116,
            height=116,

        },
        {
            -- j_ghostly
            x=6,
            y=128,
            width=116,
            height=116,

        },
        {
            -- k_ghostly
            x=128,
            y=128,
            width=116,
            height=116,

        },
        {
            -- l_ghostly
            x=250,
            y=128,
            width=116,
            height=116,

        },
        {
            -- m_ghostly
            x=372,
            y=128,
            width=116,
            height=116,

        },
        {
            -- n_ghostly
            x=494,
            y=128,
            width=116,
            height=116,

        },
        {
            -- o_ghostly
            x=616,
            y=128,
            width=116,
            height=116,

        },
        {
            -- p_ghostly
            x=738,
            y=128,
            width=116,
            height=116,

        },
        {
            -- q_ghostly
            x=860,
            y=128,
            width=116,
            height=116,

        },
        {
            -- r_ghostly
            x=982,
            y=128,
            width=116,
            height=116,

        },
        {
            -- s_ghostly
            x=6,
            y=250,
            width=116,
            height=116,

        },
        {
            -- t_ghostly
            x=128,
            y=250,
            width=116,
            height=116,

        },
        {
            -- u_ghostly
            x=250,
            y=250,
            width=116,
            height=116,

        },
        {
            -- v_ghostly
            x=372,
            y=250,
            width=116,
            height=116,

        },
        {
            -- w_ghostly
            x=494,
            y=250,
            width=116,
            height=116,

        },
        {
            -- x_ghostly
            x=616,
            y=250,
            width=116,
            height=116,

        },
        {
            -- y_ghostly
            x=738,
            y=250,
            width=116,
            height=116,

        },
        {
            -- z_ghostly
            x=860,
            y=250,
            width=116,
            height=116,

        },
    },
    
    sheetContentWidth = 1104,
    sheetContentHeight = 372
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
