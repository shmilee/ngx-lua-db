-- @Copyright (c) 2018 shmilee
-- @blockmod cclua.activity_api

local cjson = require("cjson")
local activity = require("cclua.activity")
local submitter = require("cclua.submitter")
local ngx = ngx

-- /activity/info?
-- by=next_week&day=3
-- OR
-- by=aid&first=1&long=10
-- by=title&keyword='%%'
-- by=author&author=a
-- by=a_type&a_type=b
-- by=start_datetime&day=7
local function get_activity_info(args, response)
    local dbconn, err = activity:new('ccgetter')
    if not dbconn then
        response.err = err
    else
        if args.by == nil or args.by == 'next_week' then
            response.result, response.err = dbconn:next_week(args.day)
        else
            response.result, response.err = dbconn:get_by_field(args)
        end
        if response.result then
            response.status = true
        end
        dbconn:keepalive()
    end
end

-- /activity/edit?
-- POST: { cmd='add', values={title=...,author=...} }
-- POST: { cmd='del', aid=num }
-- POST: { cmd='modify', aid=num, values={title=...,author=...} }
-- POST: { cmd='set_priority', aid=num, priority=num }
local function edit_activity_info(args, data, response)
    local dbconn, err = activity:new('ccsetter')
    if not dbconn then
        response.err = err
    else
        local cmd = data['cmd']
        if cmd == 'add' then
            response.result, response.err = dbconn:add(data.values)
        elseif cmd == 'del' then
            response.result, response.err = dbconn:del(data.aid)
        elseif cmd == 'modify' then
            response.result, response.err = dbconn:modify(data.aid, data.values)
        elseif cmd == 'set_priority' then
            response.result, response.err = dbconn:set_priority(data.aid, data.priority)
        else
            response.err = "what info to edit?"
        end
        if response.result then
            response.status = true
        end
        dbconn:keepalive()
    end
end

-- /user_login?
-- POST: { name=..., passwd=... }
-- get access_token in response.result
local function submitter_user_login(args, data, response)
    local dbconn, err = submitter:new('ccsetter')
    if not dbconn then
        response.err = err
    else
        response.result, response.err = dbconn:check_password(data.name, data.passwd)
        if response.result then
            response.status = true
        end
        dbconn:keepalive()
    end
end

-- /user_admin?
-- POST: { cmd='add', values={name=...,passwd=...} }
-- POST: { cmd='del', sid=num }
-- POST: { cmd='modify', sid=num, values={name=...,passwd=...} }
-- POST: { cmd='get_by_id', first=1, long=10 }
local function submitter_user_admin(args, data, response)
    local dbconn, err = submitter:new('ccadmin')
    if not dbconn then
        response.err = err
    else
        local cmd = data['cmd']
        if cmd == 'add' then
            response.result, response.err = dbconn:add(data.values)
        elseif cmd == 'del' then
            response.result, response.err = dbconn:del(data.sid)
        elseif cmd == 'modify' then
            response.result, response.err = dbconn:modify(data.sid, data.values)
        elseif cmd == 'get_by_id' then
            response.result, response.err = dbconn:set_priority(data.first, data.long)
        else
            response.err = "invalid command"
        end
        if response.result then
            response.status = true
        end
        dbconn:keepalive()
    end
end

local function entry()
    local request_method = ngx.req.get_method()
    local args, err = ngx.req.get_uri_args()
    local response = { status = false, result = nil, err = nil }
    if 'GET' == request_method then
        -- Route
        if '/activity/info' == ngx.var.uri then
            get_activity_info(args, response)
        end
    elseif 'POST' == request_method then
        ngx.req.read_body()
        local body_str = ngx.req.get_body_data()
        if body_str == nil then
            response.err = 'ERR_NO_BODYDATA'
        else
            local status, data = pcall(cjson.decode, body_str)
            if status == false then
                response.err = 'ERR_INVALID_JSON_FORMAT'
            else
                -- Route
                if '/activity/edit' == ngx.var.uri then
                    edit_activity_info(args, data, response)
                elseif '/user_login' == ngx.var.uri then
                    submitter_user_login(args, data, response)
                elseif '/user_admin' == ngx.var.uri then
                    submitter_user_admin(args, data, response)
                end
            end
        end
    end
    if not response.status and not response.result and not response.err then
        response.err = '404 NOT FOUND'
    end
    ngx.status = ngx.HTTP_OK
    ngx.say(cjson.encode(response))
    return ngx.exit(ngx.HTTP_OK)
end

entry()
