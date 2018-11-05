-- 数据结构：KEY
-- act_flash_sale_{product}:1:stock
-- code            说明：
local NO_EXIST_KEYS_CODE = "NO_EXIST_KEYS";
local NO_EXIST_ARGV_CODE = "NO_EXIST_ARGV";
local MISS_PARAM_CODE = "MISS_PARAM";
local REDIS_MISS_KEY_CODE = "REDIS_MISS_KEY_CODE";
local UNDER_STOCK_CODE = "UNDER_STOCK";
local ERROR_CODE = "ERROR";
local SUCCESS_CODE = "SUCCESS";

-- 秒杀前缀 field
local act_flash_sale_pre ="act_flash_sale_product:";
local act_flash_sale_suf = ":stock";

-- 回滚表
local callBackTab = {};

-- 获取响应结果信息
local getResponseInfo = function(c,m)
    return {c,m};
end

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
        error(getResponseInfo(ERROR_CODE,"can not serialize a " .. t .. " type."))
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
        error(getResponseInfo(ERROR_CODE,"can not unserialize a " .. t .. " type."))
    end
    lua = "return " .. lua
    local func = loadstring(lua)
    if func == nil then
        return nil
    end
    return func()
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
local subStock = function()
    for i, v in ipairs(ARGV) do
        local act_flash_sale_tab =  unserialize(v);
        local stockNum = act_flash_sale_tab.stockNum;
        local actFlashSaleProductId =  act_flash_sale_tab.actFlashSaleProductId;

        if  stockNum == nil then
            error(getResponseInfo(MISS_PARAM_CODE,"缺失:stockNum"));
        end
        if actFlashSaleProductId == nil then
            error(getResponseInfo(MISS_PARAM_CODE,"缺失:actFlashSaleProductId"));
        end
        -- 商品key
        local ks = {};
        ks[1] = act_flash_sale_pre .. actFlashSaleProductId .. act_flash_sale_suf;
        local el = {};


        -- 验证 秒杀库存 Key 存在
        local existKey = redis.pcall("MGET",ks[1]);
        for i, v in ipairs(existKey) do
            if v == false or v == "null" then -- 不存在的数据 返回 false
                error(getResponseInfo(REDIS_MISS_KEY_CODE,"Key:" .. ks[i] .. "不存在"));
            end
        end

        -- 加秒杀库存
        local aclPStock =redis.pcall("INCRBY",ks[1], stockNum);

        el.actFlashSaleProductId = actFlashSaleProductId;
        el.stockNum = stockNum;
        callBackTab[i]=el;
    end
end

-- 减库存
local plusStock = function()
    for i, v in ipairs(callBackTab) do
        local act_flash_sale_tab = v;
        local stockNum = act_flash_sale_tab.stockNum;
        local actFlashSaleProductId =  act_flash_sale_tab.actFlashSaleProductId;

        local act_flash_sale_key = act_flash_sale_pre .. actFlashSaleProductId .. act_flash_sale_suf;


        -- 秒杀减库存 不为 nil 减库存
        if actFlashSaleProductId ~= nil then
            redis.pcall("DECRBY", act_flash_sale_key, stockNum);
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





