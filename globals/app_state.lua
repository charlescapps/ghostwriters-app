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

function M:setAppLoadedListener(listener)
    self.mainMenuListener = listener
end

function M:callAppLoadedListener()
    if type(self.mainMenuListener) == "function" then
        local listener = self.mainMenuListener
        self.mainMenuListener = nil
        listener()
    else
        self.mainMenuListener = nil
    end
end

return M

