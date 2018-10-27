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
-- product:1:stock
-- goods:1:stock
-- code            说明：
local NO_EXIST_KEYS_CODE = "NO_EXIST_KEYS";
local NO_EXIST_ARGV_CODE = "NO_EXIST_ARGV";
local MISS_PARAM_CODE = "MISS_PARAM";
local REDIS_MISS_KEY_CODE = "REDIS_MISS_KEY_CODE";
local UNDER_STOCK_CODE = "UNDER_STOCK";
local ERROR_CODE = "ERROR";



-- 商品 field
local product_pre ="product:";
local product_suf = ":stock";

-- 货品 field
local goods_pre = "goods:";
local goods_suf = ":stock";
-- 回滚表
local callBackTab = {};


-- 处理 redis 调用错误
local handleRedisCallError = function(val)
    if val.err ~= nil then  -- 报错
        error({code = ERROR_CODE,msg=val.err});
    end
end

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

-- 加库存
local plusStock = function()
    for i, v in ipairs(ARGV) do
        local goods_tab =  unserialize(v);
        local productId =  goods_tab.productId;
        local stock = goods_tab.stock;
        local goodsId =  goods_tab.goodsId;

        if productId == nil then
            error(getResponseInfo(MISS_PARAM_CODE,"缺失:productId"));
        end
        if  stock == nil then
            error(getResponseInfo(MISS_PARAM_CODE,"缺失:stock"));
        end
        if goodsId == nil then
            error(getResponseInfo(MISS_PARAM_CODE,"缺失:goodsId"));
        end
        -- 商品key
        local ks = {};
        ks[1] = product_pre .. productId .. product_suf;
        ks[2] = goods_pre .. goodsId .. goods_suf;
        local el = {};


        -- 验证 商品 与 货品 key 存在
        local existKey = redis.pcall("MGET",ks[1],ks[2]);
        for i, v in ipairs(existKey) do
            if v == false then -- 不存在的数据 返回 false
                error(getResponseInfo(REDIS_MISS_KEY_CODE,"Key:" .. ks[i] .. "不存在"));
            end
        end

        -- 加商品库存
        local aclPStock =redis.pcall("INCRBY",ks[1],stock);
        if  aclPStock == false then
            error(getResponseInfo(REDIS_MISS_KEY_CODE,"商品id:".. productId .. "库存数据缺失"))
        elseif aclPStock.err ~= nil then -- 处理调用报错
            error(getResponseInfo(ERROR_CODE,aclPStock.err));
        elseif aclPStock < 0 then
            el.productId = productId;
            el.stock = stock;
            callBackTab[i]=el;
            error(getResponseInfo(UNDER_STOCK_CODE,"商品id:".. productId .. "剩余库存不足"));
        else
            el.productId = productId;
            el.stock = stock;
            callBackTab[i]=el;
        end

        -- 加货品库存
        local aclGStock =redis.pcall("INCRBY",ks[2],stock);
        if  aclGStock == false then
            error(getResponseInfo(REDIS_MISS_KEY_CODE,"货品id:".. goodsId .. "库存数据缺失"))
        elseif aclGStock.err ~= nil then -- 处理调用报错
            error(getResponseInfo(ERROR_CODE,aclGStock.err));
        elseif aclGStock < 0 then
            el.goodsId = goodsId;
            el.stock = stock;
            callBackTab[i]=el;
            error(getResponseInfo(UNDER_STOCK_CODE,"货品id:".. goodsId .. "剩余库存不足"));
        else
            el.goodsId = goodsId;
            el.stock = stock;
            callBackTab[i]=el;
        end
    end
end

-- 减库存
local subStock = function()
    for i, v in ipairs(callBackTab) do
        local goods_tab = v;
        local productId =  goods_tab.productId;
        local stock = goods_tab.stock;
        local goodsId =  goods_tab.goodsId;

        -- 商品key
        local ks = {};
        ks[1] = product_pre .. productId .. product_suf;
        ks[2] = goods_pre .. goodsId .. goods_suf;

        -- 商品id 不为 nil 减库存
        if productId ~= nil then
            local aclPStock =redis.pcall("DECRBY",ks[1],stock);
            if  aclPStock == false then
                error(getResponseInfo(REDIS_MISS_KEY_CODE,"商品id:".. productId .. "库存数据缺失"))
            elseif aclPStock.err ~= nil then -- 处理调用报错
                error(getResponseInfo(ERROR_CODE,aclPStock.err));
            elseif aclPStock < 0 then
                el.productId = productId;
                el.stock = stock;
                callBackTab[i]=el;
                error(getResponseInfo(UNDER_STOCK_CODE,"商品id:".. productId .. "剩余库存不足"));
            else
                el.productId = productId;
                el.stock = stock;
                callBackTab[i]=el;
            end
        end

        -- 货品id 不为 nil 减库存
        if goodsId ~= nil then
            local aclGStock =redis.pcall("DECRBY",ks[2],stock);
            if  aclGStock == false then
                error(getResponseInfo(REDIS_MISS_KEY_CODE,"货品id:".. goodsId .. "库存数据缺失"))
            elseif aclGStock.err ~= nil then -- 处理调用报错
                error(getResponseInfo(ERROR_CODE,aclGStock.err));
            elseif aclGStock < 0 then
                el.goodsId = goodsId;
                el.stock = stock;
                callBackTab[i]=el;
                error(getResponseInfo(UNDER_STOCK_CODE,"货品id:".. goodsId .. "剩余库存不足"));
            else
                el.goodsId = goodsId;
                el.stock = stock;
                callBackTab[i]=el;
            end
        end


    end

end





valid_fun();
local status =xpcall(
        function()

        end,
        function()

        end);





local aa = redis.call("hget",key,product_pre .. "1:stock");

return aa;


