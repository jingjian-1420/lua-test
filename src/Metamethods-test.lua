--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/21
-- Time: 23:09
-- To change this template use File | Settings | File Templates.
--

function aa(a)
    for key,value in pairs(a) do
        print(key .. value);
    end
end

-- 定义metatable
fraction_op={}
-- 定义__add操作
function fraction_op.__add(f1,f2)
    aa(f1)
    aa(f2)
    local ret = {}
    ret.numerator = f1.numerator + f2.numerator
    ret.denominator = f1.denominator + f2.denominator
    return ret
end

-- 定义metatable
metable2={}
-- 定义__add操作
function metable2.__add(f1,f2)
    aa(f1)
    aa(f2)
    local ret = {}
    ret.numerator = f1.numerator * f2.numerator
    ret.denominator = f1.denominator * f2.denominator
    return ret
end



fraction_a = {numerator=2, denominator=3}
fraction_b = {numerator=4, denominator=5 }
fraction_c = {numerator=6, denominator=7 }
fraction_d = {numerator=8, denominator=9 }

setmetatable(fraction_a, fraction_op)
setmetatable(fraction_b, metable2)
setmetatable(fraction_c, metable2)
setmetatable(fraction_d, fraction_op)

fraction_s = fraction_a + fraction_b  + fraction_c + fraction_d
aa(fraction_s)

