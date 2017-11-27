--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/26
-- Time: 17:59
-- To change this template use File | Settings | File Templates.
--

local declaredNames = {}

function declare (name, initval)
    rawset(_G, name, initval or false)
    declaredNames[name] = true
end
setmetatable(_G, {
    __newindex = function (t, n, v)
        if not declaredNames[n] then
            error("attempt to write to undeclared var. "..n, 2)
        else
            rawset(t, n, v)   -- do the actual set
        end
    end,
    __index = function (_, n)
        if not declaredNames[n] then
            error("attempt to read undeclared var. "..n, 2)
        else
            return nil
        end
    end,
})
declare(a,1)
for key in pairs(_G) do
    print(key)
end