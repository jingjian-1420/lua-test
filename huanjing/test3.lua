--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/26
-- Time: 19:04
-- To change this template use File | Settings | File Templates.
--

local k = {}

local mt = {
    __newindex = k
}

local t = {}

setmetatable(t, mt)

print("赋值前：")
for k,v in pairs(k) do
    print(k ,v)
end
t[1] = 20
print("赋值后：t表中的值:")
for k,v in pairs(t) do
    print(k ,v)
end

print("赋值后：k表中的值:")
for k,v in pairs(k) do
    print(k ,v)
end
print(t[1])

