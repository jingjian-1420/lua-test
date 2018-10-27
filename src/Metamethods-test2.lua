--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/25
-- Time: 18:12
-- To change this template use File | Settings | File Templates.
--
-- 定义metatable
metatable1={};
-- 定义__toString
metatable1.__tostring =function(obj)
    local ste=''
    for key,value in ipairs(obj) do
        ste = ste .. key .. value
    end
    return ste
end

Set = {"a",'b','c','d'}

setmetatable(Set,metatable1)
metatable1.__metatable="not your business"
print(Set)

print(getmetatable(Set))     --> not your business
setmetatable(Set, {})  --> org.luaj.vm2.LuaError: Metamethods-test2.lua:26 cannot change a protected metatable

metatable1.__metatable=nil
setmetatable(Set, {})
print(Set)


