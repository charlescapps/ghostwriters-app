local M = {}

M.NORMAL = { num = "0", letterMult = 1, wordMult = 1 }
M.DL = {num = "1", letterMult = 2, wordMult = 1}
M.TL = {num = "2", letterMult = 3, wordMult = 1}
M.DW = {num = "3", letterMult = 1, wordMult = 2}
M.TW = {num = "4", letterMult = 1, wordMult = 3}

M.valueOf = function(str)
	if str == M.NORMAL.num then
		return M.NORMAL
	elseif str == M.DL.num then
		return M.DL
	elseif str == M.TL.num then
		return M.TW
	elseif str == M.DW.num then
		return M.DW
	elseif str == M.TW.num then
		return M.TW
	else
		error("Invalid character for a Square: " .. str)
	end

end

return M