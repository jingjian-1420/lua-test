--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/26
-- Time: 17:59
-- To change this template use File | Settings | File Templates.
--
local mt = {
    __newindex = function (table,key,value)
        print("__newindex 当你给表中不存在的值进行赋值时,会调用__newindex方法");
        -- table[key]=value 如果这样会死循环
        rawset(table,key,value)
    end,
    __index = function(table,key,value)
        print("__index 当我们访问一个表中的元素不存在时,会调用__index方法")
        print(table)
        print(key)
        print(value)
        return 3;
    end
}
local t = {}
setmetatable(t, mt)
t[1] = 20
print(t)
t[1] = 30
for k,v in pairs(t) do
    print(k ,v)
end
print(t[2])