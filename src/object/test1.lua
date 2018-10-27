--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/28
-- Time: 14:59
-- To change this template use File | Settings | File Templates.
-- 测试一下 作为原型的table
prototype={amount=1000 }
Account = {};
function Account:new(o)
    o = o or {};
    setmetatable(o,{__index=prototype})
    return o;
end
s=Account:new({name="chen"});
print("s.amount:" .. s.amount);
-- 将原型改为1200
prototype.amount=1200;
print("s.amount:" .. s.amount);
-- 将s.amount=1500;
s.amount=1500;
print("prototype.amount" .. prototype.amount)


