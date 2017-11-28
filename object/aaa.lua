--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/28
-- Time: 16:02
-- To change this template use File | Settings | File Templates.
-- 多重继承

local function search (k, plist)
    for i=1, #plist do
        local v = plist[i][k]
        if v then return v end
    end
end

-- 参数 多重继承 的类名引用
function createClass (...)
    -- 可变参数
    local arg={...};
    -- 类
    local c = {}

    function c:new (o)
        o = o or {}
        setmetatable(o, {__index = c}) -- o里面找不到的话 就到 c里面找 c 里面没有的话 就去getmetatable(c).__index里面找.
        return o
    end

    -- t table
    -- k 变量名 或者 函数名
    -- 返回 function 或者string boolean 等
    setmetatable(c, {__index = function (t, k)
        return search(k, arg)
    end})

    return c
end

Named = {aa="asd"}
function Named:getname ()
    return self.name
end

function Named:setname (n)
    self.name = n
end

Account={}

NamedAccount = createClass(Account, Named)

account = NamedAccount:new{name = "Paul"}
print(account:getname())
print(account.aa)
