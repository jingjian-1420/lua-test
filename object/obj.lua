--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/25
-- Time: 22:43
-- To change this template use File | Settings | File Templates.
-- 面向对象程序设计  这种行为违背了前面的对象应该有独立的生命周期的原则。
Account = {balance = 0 }

function Account.withdraw (v)
    Account.balance = Account.balance - v
end


Account.withdraw(100.00)

print(Account.balance)

a = Account;
Account = nil
a.withdraw(100.00)   -- ERROR!

