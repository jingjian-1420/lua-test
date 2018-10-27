--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/25
-- Time: 22:43
-- To change this template use File | Settings | File Templates.
--
Account = {balance = 0 }
print(Account)
-->Lua也提供了通过使用冒号操作符来隐藏这个参数(self)的声明。
function Account:withdraw (v)
    print(self)
    self.balance = self.balance - v
end

-- 第一种调用
-- Account.withdraw(Account,100.00)
-- 第二种调用
Account:withdraw(100.00)

print(Account.balance)

a = Account;
Account = nil
a:withdraw(100.00)
print(a.balance)

