--
-- Created by IntelliJ IDEA.
-- User: wei
-- Date: 2017/11/26
-- Time: 19:11
-- To change this template use File | Settings | File Templates.
--
a = 1
b = 2
-- change current environment
function foobar(env)
    local _ENV = env
    local ret = {}
    function ret.foo()
        print(1)
    end
    function ret.bar()
        print(2)
    end
    return ret
end
c = foobar({});
print(c)
