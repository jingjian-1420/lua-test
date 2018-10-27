--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/26
-- Time: 17:36
-- To change this template use File | Settings | File Templates.
--
local P = {}
complex = P
local function checkComplex (c)
    if not ((type(c) == "table") and
            tonumber(c.r) and tonumber(c.i)) then
        error("bad complex number", 3)
    end
end

function P.new (r, i)
    return {r=r, i=i}
end

function P.add (c1, c2)
    checkComplex(c1);
    checkComplex(c2);
    return P.new(c1.r + c2.r, c1.i + c2.i)
end
a = P.new(1,2)
b = P.new(3,4)
c = P.add(a,b)

for k,v in pairs(c) do
    print(k .. v)
end