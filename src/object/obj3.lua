--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/25
-- Time: 23:23
-- To change this template use File | Settings | File Templates.
--
Account = {
    balance=0,
    withdraw = function (self, v)
        self.balance = self.balance - v
    end
}

function Account:deposit (v)
    self.balance = self.balance + v
end

Account.deposit(Account, 200.00)
print(Account.balance)
Account:withdraw(100.00)
print(Account.balance)

