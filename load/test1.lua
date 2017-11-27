--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/27
-- Time: 14:22
-- To change this template use File | Settings | File Templates.

-- loadfile 只需编译一次，但可多次运行
f = loadfile("loadfile-test.lua");
f()
print("echo type:" .. type(f))
-- dofile 每次都会编译执行.
aa=dofile("dofile-test.lua");
print(type(aa))
dofile("dofile-test.lua");

-- require 只编译执行一次
for i = 1, 2, 1 do
    print(i)
    b=require("require-test");
    print(b)
end
print("end");


