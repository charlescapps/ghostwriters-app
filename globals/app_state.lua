local M = {}

M.appLoaded = nil
M.mainMenuListener = nil

function M:setAppLoaded()
   print("setting isAppLoaded to true")
   self.appLoaded = true
end

function M:isAppLoaded()
   return self.appLoaded
end

function M:setMainMenuListener(listener)
    self.mainMenuListener = listener
end

function M:callMainMenuListener()
    if self.mainMenuListener then
        local listener = self.mainMenuListener
        self.mainMenuListener = nil
        listener()
    end
end

return M

