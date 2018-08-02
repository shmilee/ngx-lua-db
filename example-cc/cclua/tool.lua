-- @Copyright (c) 2018 shmilee
-- @classmod cclua.tool

local mysql = require("resty.mysql")
local const = require("cclua.const")

local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local string = string
local table = table
local ngx = {
    log = ngx.log,
    ERR = ngx.ERR,
    INFO = ngx.INFO,
    quote_sql_str = ngx.quote_sql_str,
}

local _M = { _VERSION = '0.1.0' }

function _M.get_dbconn(user)
    local dbconn, err = mysql:new()
    if not dbconn then
        ngx.log(ngx.ERR, "Failed to instantiate mysql: ", err)
        return nil, err
    end
    dbconn:set_timeout(const.MYSQL.TIMEOUT)
    if not const.USER[user] then
        ngx.log(ngx.ERR, "Connection to mysql need a db user!")
        return nil, 'lost user name!'
    end
    local ok, err, errcode, sqlstate = dbconn:connect({
        host = const.MYSQL.HOST,
        port = const.MYSQL.PORT,
        database = const.MYSQL.DATABASE,
        user = user,
        password = const.USER[user]['passwd'],
        charset = const.MYSQL.DEFAULT_CHARSET,
        max_packet_size = const.MYSQL.MAX_PACKET_SIZE,
    })
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect mysql: ", err, ": ", errcode)
        return nil, err
    end
    return dbconn
end

function _M.set_keepalive(dbconn)
    if not dbconn then
        ngx.log(ngx.ERR, 'Connection needed!')
        return false
    end
    -- put it into the connection pool of size 100,
    -- with 10 seconds max idle timeout
    local ok, err = dbconn:set_keepalive(10000, 100)
    if not ok then
        ngx.log(ngx.ERR, "failed to set keepalive: ", err)
        return false
    end
    return true
end

-- Insert data into dbtable
-- @param fields, {{name,auto,ftype,default}, {...}, ...}
--        auto(true, false), ftype(num,str)
-- @param values {field1='', field2=12, ...}
function _M.query_insert(dbconn, dbtable, fields, values)
    if not dbconn then
        local err = "Connection needed to query insert!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local field_str, value_str = {}, {}
    for n, fi in pairs(fields) do
        if not fi.auto then
            local val = values[fi.name] or fi.default
            if fi.ftype == 'num' then
                val = tonumber(val)
            elseif fi.ftype == 'str' then
                val = ngx.quote_sql_str(tostring(val))
            end
            table.insert(field_str, fi.name)
            table.insert(value_str, val)
        end
    end
    local query_str = string.format("insert into %s (%s) values (%s)",
        dbtable, table.concat(field_str, ', '), table.concat(value_str, ', '))
    --ngx.log(ngx.ERR, query_str)
    local res, err, errcode, sqlstate = dbconn:query(query_str)
    if not res then
        ngx.log(ngx.ERR, "Insert bad result: ", err, ": ", errcode)
        return nil, err
    end
    ngx.log(ngx.INFO,
        string.format("%s rows inserted into table %s, (last insert id: %s)",
            res.affected_rows, dbtable, res.insert_id))
    return res
end

-- Delete data from dbtable
-- @param condition, string
function _M.query_delete(dbconn, dbtable, condition)
    if not dbconn then
        local err = "Connection needed to query delete!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    if not condition then
        local err = "Condition needed to query delete!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local query_str = string.format(
        "delete from %s where %s", dbtable, condition)
    --ngx.log(ngx.ERR, query_str)
    local res, err, errcode, sqlstate = dbconn:query(query_str)
    if not res then
        ngx.log(ngx.ERR, "Delete bad result: ", err, ": ", errcode)
        return nil, err
    end
    ngx.log(ngx.INFO, string.format("%s rows deleted from table %s",
        res.affected_rows, dbtable))
    return res
end

-- Select data from dbtable
-- @param condition, string
function _M.query_select(dbconn, dbtable, condition)
    if not dbconn then
        local err = "Connection needed to query select!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    if not condition then
        local err = "Condition needed to query select!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local query_str = string.format(
        "select * from %s where %s", dbtable, condition)
    --ngx.log(ngx.ERR, query_str)
    local res, err, errcode, sqlstate = dbconn:query(query_str)
    if not res then
        ngx.log(ngx.ERR, "Select bad result: ", err, ": ", errcode)
        return nil, err
    end
    return res
end

-- Update data in dbtable
-- @param data, {field1=expr1, field2=expr2, ...}
--      check or quote expr by yourself
-- @param condition, string
function _M.query_update(dbconn, dbtable, data, condition)
    if not dbconn then
        local err = "Connection needed to query update!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    if not condition then
        local err = "Condition needed to query update!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local data_str = {}
    for field, expr in pairs(data) do
        table.insert(data_str, field .. ' = ' .. expr)
    end
    local query_str = string.format("update %s set %s where %s",
        dbtable, table.concat(data_str, ', '), condition)
    --ngx.log(ngx.ERR, query_str)
    local res, err, errcode, sqlstate = dbconn:query(query_str)
    if not res then
        ngx.log(ngx.ERR, "Update bad result: ", err, ": ", errcode)
        return nil, err
    end
    ngx.log(ngx.INFO, string.format("%s rows updated in table %s",
        res.affected_rows, dbtable))
    return res
end

return _M
