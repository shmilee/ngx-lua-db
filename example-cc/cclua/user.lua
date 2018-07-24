-- Copyright (c) 2018 shmilee

local mysql = require("resty.mysql")
local const = require("cclua.const")
local ngx = {
    log = ngx.log,
    ERR = ngx.ERR,
    INFO = ngx.INFO,
    quote_sql_str = ngx.quote_sql_str,
}

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

function _M:new()
    local dbconn, err = mysql:new()
    if not dbconn then
        ngx.log(ngx.ERR, "Failed to instantiate mysql: ", err)
        return nil, err
    end
    dbconn:set_timeout(const.MYSQL.TIMEOUT)

    local ok, err, errcode, sqlstate = dbconn:connect({
        host = const.MYSQL.HOST,
        port = const.MYSQL.PORT,
        database = const.MYSQL.DATABASE,
        user = const.MYSQL.ADMIN_USER,
        password = const.MYSQL.ADMIN_PASSWORD,
        charset = const.MYSQL.DEFAULT_CHARSET,
        max_packet_size = const.MYSQL.MAX_PACKET_SIZE,
    })
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect mysql: ", err, ": ", errcode)
        return nil, err
    end
    return setmetatable({ dbconn = dbconn }, mt)
end

function _M:add_user(opts)
    local dbconn = self.dbconn
    if not dbconn then
        local err = "Connection needed to query insert!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local name = ngx.quote_sql_str(opts.name or 'username')
    local passwd = ngx.quote_sql_str(opts.passwd or '123456')
    local u_group = tonumber(opts.u_group or 1)
    local employer = ngx.quote_sql_str(opts.employer or 'not-set')
    local sql = "insert into " .. const.MYSQL.ADMIN_TABLE .. " (name, passwd, u_group, employer) values (" .. table.concat({name, passwd, u_group, employer}, ', ') .. ")"
    ngx.log(ngx.INFO, sql)
    local res, err, errcode, sqlstate = dbconn:query(sql)
    if not res then
        ngx.log(ngx.ERR, "Insert bad result: ", err, ": ", errcode)
        return nil, err
    end
    ngx.log(ngx.INFO, res.affected_rows, " rows inserted into table " .. const.MYSQL.ADMIN_TABLE .. ", (last insert id: ", res.insert_id, ")")
    return res
end

-- _M.upd_user()

function _M:rmv_user(opts)
    local dbconn = self.dbconn
    if not dbconn then
        local err = "Connection needed to query delete!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local u_id = tonumber(opts.u_id or -1)
    if u_id < 0 then
        err = "u_id should >=0!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local sql = "delete from " .. const.MYSQL.ADMIN_TABLE .. " where u_id=" .. u_id
    ngx.log(ngx.INFO, sql)
    local res, err, errcode, sqlstate = dbconn:query(sql)
    if not res then
        ngx.log(ngx.ERR, "Insert bad result: ", err, ": ", errcode)
        return nil, err
    end
    ngx.log(ngx.INFO, res.affected_rows, " rows inserted into table " .. const.MYSQL.ADMIN_TABLE .. ", (last insert id: ", res.insert_id, ")")
    return res
end

function _M:select_user(name)
    local dbconn = self.dbconn
    if not dbconn then
        local err = "Connection needed to query insert!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local name = ngx.quote_sql_str(opts.name)
    local sql = "select * from " .. const.MYSQL.ADMIN_TABLE .. " where name=" .. name .. "limit 1"
    ngx.log(ngx.INFO, sql)
    local res, err, errcode, sqlstate = dbconn:query(sql)
    if not res then
        ngx.log(ngx.ERR, "Insert bad result: ", err, ": ", errcode)
        return nil, err
    end
    ngx.log(ngx.INFO, res.affected_rows, " rows inserted into table " .. const.MYSQL.ADMIN_TABLE .. ", (last insert id: ", res.insert_id, ")")
    return res
end

function _M:spare_conn()
    local dbconn = self.dbconn
    if not dbconn then
        local err = "Connection needed to put in pool!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    -- put it into the connection pool of size 100,
    -- with 10 seconds max idle timeout
    local ok, err = dbconn:set_keepalive(10000, 100)
    if not ok then
        ngx.log(ngx.ERR, "failed to set keepalive: ", err)
        return nil, err
    else
        return ok
    end
end

return _M
