--
-- Created by IntelliJ IDEA.
-- User: charlescapps
-- Date: 3/16/15
-- Time: 8:57 PM
-- To change this template use File | Settings | File Templates.
--
local M = {}

local pointMap = {
    A=1,
    B=3,
    C=3,
    D=3,
    E=1,
    F=4,
    G=2,
    H=4,
    I=2,
    J=10,
    K=7,
    L=2,
    M=3,
    N=2,
    O=2,
    P=4,
    Q=15,
    R=1,
    S=1,
    T=1,
    U=2,
    V=6,
    W=4,
    X=9,
    Y=5,
    Z=12,
    ["*"] = 0
}

M.getLetterPoints = function(letter)
    return pointMap[letter:upper()]
end

return M

