local serialize= function(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{\n"
        for k, v in pairs(obj) do
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
            end
        end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end

local  unserialize = function(lua)
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    lua = "return " .. lua
    local func = loadstring(lua)
    if func == nil then
        return nil
    end
    return func()
end

-- 数据结构：KEY
-- {product}:1:stock
-- {product}_goods:1:stock
-- code            说明：
local NO_EXIST_KEYS_CODE = "NO_EXIST_KEYS";
local NO_EXIST_ARGV_CODE = "NO_EXIST_ARGV";
local MISS_PARAM_CODE = "MISS_PARAM";
local REDIS_MISS_KEY_CODE = "REDIS_MISS_KEY_CODE";
local UNDER_STOCK_CODE = "UNDER_STOCK";
local ERROR_CODE = "ERROR";
local SUCCESS_CODE = "SUCCESS";

-- 商品 field
local product_pre ="{product}:";
local product_suf = ":stock";

-- 货品 field
local goods_pre = "{product}_goods:";
local goods_suf = ":stock";
-- 回滚表
local callBackTab = {};

-- 获取响应结果信息
local getResponseInfo = function(c,m)
    return {code=c,msg=m};
end

-- 验证
local valid = function()
    if #KEYS == 0 then
        return  getResponseInfo(NO_EXIST_KEYS_CODE,"KEYS为空");
    end

    if #ARGV == 0 then
        return getResponseInfo(NO_EXIST_ARGV_CODE,"ARGV为空");
    end
end

-- 减库存
local subStock = function()
    for i, v in ipairs(ARGV) do
        local goods_tab =  unserialize(v);
        local productId =  goods_tab.productId;
        local stockNum = goods_tab.stockNum;
        local productGoodsId =  goods_tab.productGoodsId;

        if productId == nil then
            error(getResponseInfo(MISS_PARAM_CODE,"缺失:productId"));
        end
        if  stockNum == nil then
            error(getResponseInfo(MISS_PARAM_CODE,"缺失:stockNum"));
        end
        if productGoodsId == nil then
            error(getResponseInfo(MISS_PARAM_CODE,"缺失:productGoodsId"));
        end
        -- 商品key
        local ks = {};
        ks[1] = product_pre .. productId .. product_suf;
        ks[2] = goods_pre .. productGoodsId .. goods_suf;
        local el = {};


        -- 验证 商品 与 货品 key 存在
        local existKey = redis.pcall("MGET",ks[1],ks[2]);
        for i, v in ipairs(existKey) do
            if v == false then -- 不存在的数据 返回 false
                error(getResponseInfo(REDIS_MISS_KEY_CODE,"Key:" .. ks[i] .. "不存在"));
            end
        end

        -- 减商品库存
        local aclPStock =redis.pcall("DECRBY",ks[1], stockNum);

        if aclPStock.err ~= nil then -- 处理调用报错
            error(getResponseInfo(ERROR_CODE,aclPStock.err));
        elseif aclPStock < 0 then
            el.productId = productId;
            el.stockNum = stockNum;
            callBackTab[i]=el;
            error(getResponseInfo(UNDER_STOCK_CODE,"商品id:".. productId .. "剩余库存不足"));
        else
            el.productId = productId;
            el.stockNum = stockNum;
            callBackTab[i]=el;
        end

        -- 减货品库存
        local aclGStock =redis.pcall("DECRBY",ks[2], stockNum);
        if aclGStock.err ~= nil then -- 处理调用报错
            error(getResponseInfo(ERROR_CODE,aclGStock.err));
        elseif aclGStock < 0 then
            el.productGoodsId = productGoodsId;
            el.stockNum = stockNum;
            callBackTab[i]=el;
            error(getResponseInfo(UNDER_STOCK_CODE,"货品id:".. productGoodsId .. "剩余库存不足"));
        else
            el.productGoodsId = productGoodsId;
            el.stockNum = stockNum;
            callBackTab[i]=el;
        end
    end
end

-- 加库存
local plusStock = function()
    for i, v in ipairs(callBackTab) do
        local goods_tab = v;
        local productId =  goods_tab.productId;
        local stockNum = goods_tab.stockNum;
        local productGoodsId =  goods_tab.productGoodsId;

        local product_key = product_pre .. productId .. product_suf;
        local goods_key= goods_pre .. productGoodsId .. goods_suf;

        -- 商品id 不为 nil 加库存
        if productId ~= nil then
            redis.pcall("INCRBY",product_key, stockNum);
        end

        -- 货品id 不为 nil 加库存
        if productGoodsId ~= nil then
            redis.pcall("INCRBY",goods_key, stockNum);
        end
    end
end

local result = valid();
if result == nil then
    local status,r =xpcall(
            function()
                --减库存
                subStock();
               return getResponseInfo(SUCCESS_CODE,"成功");
            end,
            function(e)
                -- 加库存
                plusStock();
                return e;
            end);
    result = r;
end

return result;





