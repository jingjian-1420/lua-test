--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/25
-- Time: 22:43
-- To change this template use File | Settings | File Templates.
--
Account = {balance = 0}

function Account.withdraw (self, v)
    self.balance = self.balance - v
end


Account.withdraw(Account,100.00)

print(Account.balance)

a = Account;
Account = nil
a.withdraw(a,100.00)
print(a.balance)

