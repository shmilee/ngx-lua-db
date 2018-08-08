-- @Copyright (c) 2018 shmilee
-- @classmod cclua.submitter

local tool = require("cclua.tool")

local setmetatable = setmetatable
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local string = string
local type = type
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
    { name = 'sid', auto = true, ftype = 'num', default = nil },
    { name = 'name',             ftype = 'str', default = nil },
    { name = 'passwd',           ftype = 'str', default = nil },
    { name = 'salt',             ftype = 'str', default = nil },
    { name = 'sgroup',           ftype = 'num', default = 1 },
    { name = 'employer',         ftype = 'str', default = nil },
    { name = 'access_token',     ftype = 'str', default = nil },
    { name = 'reserve',          ftype = 'str', default = nil },
}

function _M:new(user)
    return tool.get_dbconn(user, 'submitter', mt)
end

function _M:keepalive()
    return tool.set_keepalive(self.dbconn)
end

function _M:add(values)
    if type(values) == 'table' then
        values.passwd, values.salt = tool.secure_password(values.passwd, nil)
    end
    return tool.query_insert(self.dbconn, 'submitter', fields, values)
end

function _M:del(sid)
    local sid = tonumber(sid)
    if not sid then
        local err = "No submitter ID to delete!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    return tool.query_delete(self.dbconn, 'submitter', "sid=" .. sid)
end

function _M:modify(sid, values)
    local sid = tonumber(sid)
    if not sid then
        local err = "No submitter ID to modify!"
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
                    if fi.name == 'passwd' then
                        val, valid.salt = tool.secure_password(values.passwd, nil)
                        valid.salt = ngx.quote_sql_str(valid.salt)
                    end
                    val = ngx.quote_sql_str(tostring(val))
                end
                if fi.name ~= 'salt' then
                    valid[fi.name] = val
                end
            end
        end
    end
    if next(valid) == nil then
        local err = "NO submitter values to modify!"
        ngx.log(ngx.ERR, err)
        return nil, err
    end
    return tool.query_update(self.dbconn, 'submitter', valid, "sid=" .. sid)
end

function _M:get_by_id(first, long)
    local first = math.floor(tonumber(first) or 1)
    local last = first + math.floor(tonumber(long) or 10)
    return tool.query_select(
        self.dbconn, 'submitter', {'sid', 'name', 'sgroup', 'employer' },
        string.format("sid>=%d AND sid<%d", first, last))
end

-- return result:{access_token}, err
function _M:check_password(name, passwd)
    if not name or not passwd then
        return nil, 'Lost user name or password!'
    end
    local res, err = tool.query_select(
        self.dbconn, 'submitter', { 'passwd', 'salt', 'access_token' },
        string.format("name=%s limit 1", ngx.quote_sql_str(tostring(name))))
    if not res then
        return nil, err
    end
    if not res[1] or type(res[1]) ~= 'table' then
        return nil, string.format("Invalid user name %s!", name)
    end
    passwd, _ = tool.secure_password(passwd, res[1].salt)
    if passwd == res[1].passwd then
        return { access_token = res[1].access_token }, nil
    else
        return nil, string.format("Wrong password for user %s!", name)
    end
end

-- check_token

return _M
