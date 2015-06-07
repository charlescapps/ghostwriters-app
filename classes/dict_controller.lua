local dict_page = require("classes.dict_page")
local math = require("math")
local transition = require("transition")

local M = {}
local meta = { __index = M }

local WORDS_PER_PAGE = 12

function M.new(scene, dict)
    local dictController = {
        scene = scene,
        dict = dict,
        currentPage = 1
    }
    return setmetatable(dictController, meta)
end

function M:render()
    local function onReleaseNextPage()
        self:nextPage()
    end
    local function onReleasePrevPage()
        self:prevPage()
    end
    print("Creating new dict page. self.currentPage = " .. self.currentPage)
    self.dictPage = dict_page.new(self.dict.specialDict, self:computePageWords(), self.currentPage, self:computeTotalPages(),
        self:computeTotalPlayed(), self:getTotalWords(), onReleaseNextPage, onReleasePrevPage)
    self:insertDictPageIntoScene()
end

function M:insertDictPageIntoScene()
    print("Attempting to insert dict page into scene...")
    if self.scene and self.scene.view and self.scene.view.insert and self.dictPage then
        print("Fading in dict page...")
        self.dictPage:render()
        self.dictPage.view.alpha = 0
        self.scene.view:insert(self.dictPage.view)
        transition.fadeIn(self.dictPage.view, { time = 1000 })
    end
end

function M:removeDictPage()
    if self.dictPage then
        local oldDictPage = self.dictPage
        oldDictPage:disableArrows()
        oldDictPage:destroy()
    end
end

function M:computePageWords()
    local allWords = self.dict.words
    local startIndex = WORDS_PER_PAGE * (self.currentPage - 1) + 1
    local pageWords = {}
    for i = startIndex, startIndex + WORDS_PER_PAGE - 1 do
        pageWords[#pageWords + 1] = allWords[i]
    end
    return pageWords
end

function M:computeTotalPages()
    local totalWords = self:getTotalWords()
    return math.ceil(totalWords / WORDS_PER_PAGE)
end

function M:computeTotalPlayed()
    local allWords = self.dict.words
    local numPlayed = 0
    for i = 1, #allWords do
       local word = allWords[i]
        if word.p then
            numPlayed = numPlayed + 1
        end
    end
    return numPlayed
end

function M:getTotalWords()
    return #self.dict.words
end

function M:nextPage()
    local totalPages = self:computeTotalPages()
    if self.currentPage >= totalPages then
        print("Can't go to the next page, already at page: " .. self.currentPage)
        return
    end
    self:removeDictPage()
    self.currentPage = self.currentPage + 1
    self:render()
end

function M:prevPage()
    if self.currentPage <= 1 then
        print("Can't go to the prev page, already at page: " .. self.currentPage)
        return
    end
    self:removeDictPage()
    self.currentPage = self.currentPage - 1
    self:render()
end


return M

