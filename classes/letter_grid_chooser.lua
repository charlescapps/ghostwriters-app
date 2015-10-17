local display = require("display")
local tile = require("common.tile")
local math = require("math")

local ROW_SIZE = 5

local M = {}

local __meta = { __index = M }

function M.new(opts)
    opts = opts or {}
    local letterGridChooser = {
        x = opts.x or 0,
        y = opts.y or 0,
        tileSize = opts.tileSize or 100,
        padding = opts.padding or 2,
        selectedLetter = "A",
        letterImages = {}
    }

    return setmetatable(letterGridChooser, __meta)
end

function M:render()
    local group = display.newGroup()
    group.x, group.y = self.x, self.y

    -- The 26 letters of the alphabet laid out in a grid.
    for i = 0, 25 do
        local tileImg = self:createTileImg(i)
        self.letterImages[tileImg.letter] = tileImg
        group:insert(tileImg)
    end

    self.view = group

    self:selectLetterByString(self.selectedLetter)

    return group
end

function M:createTileImg(i)
    local letter = string.char(65 + i)
    local x, y = self:computeCoords(i)
    local tileImg = tile.draw(letter, x, y, self.tileSize, true)
    tileImg.letter = letter

    local function onTouch(event)
        if "ended" == event.phase then
           print("Touched tile: " .. tostring(event.target.letter))
            self:selectLetterByImg(event.target)
        end
    end

    tileImg:addEventListener("touch", onTouch)

    return tileImg
end

function M:selectLetterByString(letter)
    if type(letter) ~= "string" then
        return
    end

    print("Selecting letter: " .. letter)

    local tileImg = self.letterImages[letter]

    self:selectLetterByImg(tileImg)
end

function M:selectLetterByImg(tileImg)
    if not tileImg then
        return
    end

    local letter = tileImg.letter

    if type(letter) ~= "string" then
        return
    end

    -- Select the letter
    self.selectedLetter = letter

    -- Remove shiny from all other tiles
    for i = 0, 25 do
        local tmpLetter = string.char(65 + i)
        local tmpImg = self.letterImages[tmpLetter]

        if tmpImg then
            tmpImg.fill.effect = nil
        end
    end

    -- Make the tile shiny
    tileImg.fill.effect = "filter.brightness"
    tileImg.fill.effect.intensity = 0.6
end

-- index is from 0, ... , 25
function M:computeCoords(index)
    local TILE_DIST = self.tileSize + self.padding

    local X_START = -2 * TILE_DIST
    local Y_START = -2 * TILE_DIST

    local x = X_START + index % ROW_SIZE * TILE_DIST
    local y = Y_START + math.floor(index / ROW_SIZE) * TILE_DIST

    return x, y
end

return M

