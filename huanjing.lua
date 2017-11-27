--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/25
-- Time: 20:42
-- To change this template use File | Settings | File Templates.
--
setmetatable(_G, {
    -- 新变量时 调用
    __newindex = function (_, n)
        error("attempt to write to undeclared variable " .. n, 2)
    end,
    -- 读变量时 调用
    __index = function (_, n)
        error("attempt to read undeclared variable "..n, 2)
    end
})

print(a)

