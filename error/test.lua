--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/28
-- Time: 10:34
-- To change this template use File | Settings | File Templates.
-- pcall 返回状态 与 错误信息
--local status,err = pcall(function()
--local i = io.read("*n");
--if i == 10 then
--    print(i)
--else
--    error("error exception")
--end
--end)

--xpcall 输入参数 调用函数、错误处理函数
function it(o)
    print(type(o))
    for k,v in pairs(o) do
        print(k .. v)
    end
end

local a,b,c=xpcall(function()
    local i = io.read("*n");
    if i == 10 then
        print(i)
    else
        error({aa="bb"})
    end
end,function(d)
    print(d)
    print(debug.debug())
    print(debug.traceback())
end)
print(a)

