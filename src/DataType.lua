---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by wei.
--- DateTime: 2018/10/25 20:07
---
-- 定义数组
local keys = {"a","b","c"} ;
local args = {{product=1,stock=1}};

--result = {};
--for i, v in ipairs(keys) do
--    result[i] = {}
--end
for i, v in ipairs(keys) do
    print(i .. v)
end

for k, v in pairs(args) do
    print(k .. v.product .. v.stock)
end