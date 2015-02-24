local table = require("table")
local M = {}

M.indexOf = function(list, item)
	for i = 1, #list do
		local obj = list[i]
		if obj == item then
			return i
		end
	end
	return -1
end

M.removeFromList = function(list, item)
	for i = 1, #list do
		local obj = list[i]
		if obj == item then
			table.remove(list, i)
			return
		end
	end
end

return M