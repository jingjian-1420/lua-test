--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/28
-- Time: 14:17
-- To change this template use File | Settings | File Templates.
-- 主要__index 在读取不存在的变量时会调用,__newindex 在新增变量时会调用。
--继承
Account = {balance = 0}

function Account:new (o)
    o = o or {}
    setmetatable(o, {__index=self})
    return o
end

-- 存款
function Account:deposit (v)
    self.balance = self.balance + v
end

-- 撤销
function Account:withdraw (v)
    if v > self.balance then error"insufficient funds" end
    self.balance = self.balance - v
end

--[[
 派生子类
 会员 姓名：chen
 消费折扣8折
 充值3000
 消费2000 打8折 实际消费1400
 余额1400
--]]
SpecialAccount = Account:new({username="chen"});
-- 会员购物
SpecialAccount.vipBuy=function(self,v)
    self.balance=self.balance - (v * self.limit() )
end
-- 会员折扣8折
function SpecialAccount:limit(v)
    return 0.8;
end

-- 存款3000
SpecialAccount.deposit(SpecialAccount,3000);
-- 打印余额
print("余额:" .. SpecialAccount.balance);
-- 消费 2000 打8折 = 1600
SpecialAccount:vipBuy(2000);
-- 打印余额 3000 - 1600 = 1400
print("余额:" .. SpecialAccount.balance);

--[[
  派生子类
  升级成超级会员 购物 打 1折
  充值 1000
  消费2000 打1折 实际消费 200
--]]
s=SpecialAccount.new(SpecialAccount)
-- 重写 会员折扣
function s:limit(v)
    return 0.1;
end
-- 存款1000
s:deposit(1000);
-- 打印余额
print("余额:" .. s.balance);
-- 消费 2000 打1折 = 200
s:vipBuy(2000);
-- 打印余额 2400 - 200 = 2200
print("余额:" .. s.balance);

-- 降级成 会员 消费 1000 8折 800
s.vipBuy(SpecialAccount,1000)
print("余额:" .. s.balance);
print("余额:" .. SpecialAccount.balance);
