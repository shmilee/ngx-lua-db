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

function _M:new(action)
    local dbconn, err = mysql:new()
    if not dbconn then
        ngx.log(ngx.ERR, "Failed to instantiate mysql: ", err)
        return nil, err
    end
    dbconn:set_timeout(const.MYSQL.TIMEOUT)
    local user, passwd = nil, nil
    if action == 'set' then
        user, passwd = const.MYSQL.SET_USER, const.MYSQL.SET_PASSWORD
    else
        user, passwd = const.MYSQL.GET_USER, const.MYSQL.GET_PASSWORD
    end
    local ok, err, errcode, sqlstate = dbconn:connect({
        host = const.MYSQL.HOST,
        port = const.MYSQL.PORT,
        database = const.MYSQL.DATABASE,
        user = user,
        password = passwd,
        charset = const.MYSQL.DEFAULT_CHARSET,
        max_packet_size = const.MYSQL.MAX_PACKET_SIZE,
    })
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect mysql: ", err, ": ", errcode)
        return nil, err
    end
    return setmetatable({ dbconn = dbconn }, mt)
end

function _M:add_activity(opts)
    local dbconn = self.dbconn
    if not dbconn then
        local err = "Connection needed to query insert!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end

    local priority = tonumber(opts.priority or 1)
    local title = ngx.quote_sql_str(opts.title)
    local author = ngx.quote_sql_str(opts.author)
    local a_host = ngx.quote_sql_str(opts.a_host)
    local contact = ngx.quote_sql_str(opts.contact)
    local submission_datetime = ngx.quote_sql_str(opts.submission_datetime)
    local start_datetime = ngx.quote_sql_str(opts.start_datetime)
    local duration = ngx.quote_sql_str(opts.duration)
    local longitude = tonumber(opts.longitude)
    local latitude = tonumber(opts.latitude)
    local location = ngx.quote_sql_str(opts.location)
    local a_type = ngx.quote_sql_str(opts.a_type)
    local reservation = ngx.quote_sql_str(opts.reservation)
    local introduction = ngx.quote_sql_str(opts.introduction)
    local sql = "insert into " .. const.MYSQL.ACT_TABLE ..
        " (priority, title, author, a_host, contact," ..
        "  submission_datetime, start_datetime, duration," ..
        "  longitude, latitude, location," ..
        "  a_type, reservation, introduction) values (" ..
        table.concat({
            priority, title, author, a_host, contact,
            submission_datetime, start_datetime, duration,
            longitude, latitude, location,
            a_type, reservation, introduction}, ', ') .. ")"
    -- ngx.log(ngx.INFO, sql)
    local res, err, errcode, sqlstate = dbconn:query(sql)
    if not res then
        ngx.log(ngx.ERR, "Insert bad result: ", err, ": ", errcode)
        return nil, err
    end
    ngx.log(ngx.INFO, res.affected_rows, " rows inserted into table " .. const.MYSQL.ACT_TABLE .. ", (last insert id: ", res.insert_id, ")")
    return res
end

function _M:rmv_activity(opts)
    local dbconn = self.dbconn
    if not dbconn then
        local err = "Connection needed to query delete!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local a_id = tonumber(opts.a_id or -1)
    if a_id < 0 then
        err = "a_id should >=0!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local sql = "delete from " .. const.MYSQL.ACT_TABLE .. " where a_id=" .. a_id
    -- ngx.log(ngx.INFO, sql)
    local res, err, errcode, sqlstate = dbconn:query(sql)
    if not res then
        ngx.log(ngx.ERR, "Insert bad result: ", err, ": ", errcode)
        return nil, err
    end
    ngx.log(ngx.INFO, res.affected_rows, " rows deleted from table " .. const.MYSQL.ACT_TABLE .. ", (last delete id: ", res.insert_id, ")")
    return res
end

function _M:next_week_activity(opts)
    local dbconn = self.dbconn
    if not dbconn then
        local err = "Connection needed to query delete!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local n = 7
    if opts then
        n = tonumber(opts.n)
    end
    local sql = "select * from " .. const.MYSQL.ACT_TABLE ..
        " where CURDATE() <= DATE(start_datetime) AND DATE(start_datetime) < DATE_ADD(CURDATE(), INTERVAL " .. n .. " DAY)" ..
        " AND priority > 0"
    -- ngx.log(ngx.INFO, sql)
    local res, err, errcode, sqlstate = dbconn:query(sql)
    if not res then
        ngx.log(ngx.ERR, "Insert bad result: ", err, ": ", errcode)
        return nil, err
    end
    ngx.log(ngx.INFO, res.affected_rows, " rows deleted from table " .. const.MYSQL.ACT_TABLE .. ", (last delete id: ", res.insert_id, ")")
    return res
end

-- M2.off_activity()

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
