-- @Copyright (c) 2018 shmilee
-- @classmod cclua.activity

local tool = require("cclua.tool")

local setmetatable = setmetatable
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local string = string
local next = next
local math = math
local ngx = {
    log = ngx.log,
    ERR = ngx.ERR,
    quote_sql_str = ngx.quote_sql_str,
}

local _M = { _VERSION = '0.1.0' }
local mt = { __index = _M }
local fields = {
    { name = 'aid',  auto = true,   ftype = 'num', default = nil },
    { name = 'priority',            ftype = 'num', default = 0 },
    { name = 'title',               ftype = 'str', default = nil },
    { name = 'author',              ftype = 'str', default = nil },
    { name = 'a_host',              ftype = 'str', default = nil },
    { name = 'contact',             ftype = 'str', default = nil },
    { name = 'submission_datetime', ftype = 'str', default = nil },
    { name = 'start_datetime',      ftype = 'str', default = nil },
    { name = 'duration',            ftype = 'str', default = nil },
    { name = 'longitude',           ftype = 'num', default = nil },
    { name = 'latitude',            ftype = 'num', default = nil },
    { name = 'location',            ftype = 'str', default = nil },
    { name = 'a_type',              ftype = 'str', default = nil },
    { name = 'reservation',         ftype = 'str', default = nil },
    { name = 'introduction',        ftype = 'str', default = nil },
    { name = 'reserve',             ftype = 'str', default = nil },
}

function _M:new(user)
    local dbconn, err = tool.get_dbconn(user)
    if not dbconn then
        return nil, err
    end
    return setmetatable({ dbconn = dbconn }, mt)
end

function _M:keepalive()
    return tool.set_keepalive(self.dbconn)
end

function _M:add(values)
    if not values then
        local err = "NO activity values to add!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    return tool.query_insert(self.dbconn, 'activity', fields, values)
end

function _M:del(aid)
    local aid = tonumber(aid)
    if not aid then
        local err = "No activity ID to delete!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    return tool.query_delete(self.dbconn, 'activity', "aid=" .. aid)
end

function _M:get_by_id(first, long)
    local first = math.floor(tonumber(first) or 1)
    local last = first + math.floor(tonumber(long) or 10)
    return tool.query_select(self.dbconn, 'activity',
        string.format("aid>=%d AND aid<%d", first, last))
end

function _M:get_by_author(author)
    if not author then
        local err = "No author to select!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local author = ngx.quote_sql_str(author)
    return tool.query_select(self.dbconn, 'activity', "author=" .. author)
end

function _M:get_by_type(a_type)
    if not a_type then
        local err = "No activity type to select!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local a_type = ngx.quote_sql_str(a_type)
    return tool.query_select(self.dbconn, 'activity', "a_type=" .. a_type)
end

function _M:next_week(day)
    local day = math.floor(tonumber(day) or 7)
    return tool.query_select(self.dbconn, 'activity',
        "CURDATE() <= DATE(start_datetime) AND DATE(start_datetime) < DATE_ADD(CURDATE(), INTERVAL " .. day .. " DAY) AND priority > 0")
end

function _M:modify(aid, values)
    local aid = tonumber(aid)
    if not aid then
        local err = "No activity ID to modify!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    local valid = {}
    if values and next(values) ~= nil then
        for n, fi in pairs(fields) do
            local val = values[fi.name]
            if not fi.auto and val then
                if fi.ftype == 'num' then
                    val = tonumber(val)
                elseif fi.ftype == 'str' then
                    val = ngx.quote_sql_str(tostring(val))
                end
                valid[fi.name] = val
            end
        end
    end
    if next(valid) == nil then
        local err = "NO activity values to modify!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    return tool.query_update(self.dbconn, 'activity', valid, "aid=" .. aid)
end

function _M:set_priority(aid, priority)
    return self:modify(aid, { priority = priority })
end

return _M
