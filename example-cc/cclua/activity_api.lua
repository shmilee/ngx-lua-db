-- @Copyright (c) 2018 shmilee
-- @blockmod cclua.activity_api

local cjson = require("cjson")
local activity = require("cclua.activity")
local ngx = ngx

-- /activity/info?
-- by=id&first=1&long=10
-- by=author&author=a
-- by=a_type&a_type=b
-- by=week&day=3
local function get_info(args)
    local dbconn, err = activity:new('ccgetter')
    local response = { status = false, err = nil }
    if not dbconn then
        response.err = err
    else
        local res
        if args.by == nil or args.by == 'id' then
            res, err = dbconn:get_by_id(args.first, args.long)
        elseif args.by == 'author' then
            res, err = dbconn:get_by_author(args.author)
        elseif args.by == 'a_type' then
            res, err = dbconn:get_by_type(args.a_type)
        elseif args.by == 'week' then
            res, err = dbconn:next_week(args.day)
        else
            res, err = nil, "get info by what?"
        end
        if not res then
            response.err = err
        else
            response.result = res
            response.status = true
        end
        dbconn:keepalive()
    end
    ngx.status = ngx.HTTP_OK  
    ngx.say(cjson.encode(response))
    return ngx.exit(ngx.HTTP_OK)
end

-- /activity/edit?
-- POST: { cmd='add', values={title=...,author=...} }
-- POST: { cmd='del', aid=num }
-- POST: { cmd='modify', aid=num, values={title=...,author=...} }
-- POST: { cmd='set_priority', aid=num, priority=num }
local function edit_info(args)
    ngx.req.read_body()
    local body_str = ngx.req.get_body_data()
    local response = { status = false, err = nil }    
    if body_str == nil then
        response.err = 'ERR_NO_BODYDATA'
    else
        local status, data = pcall(cjson.decode, body_str)
        if status == false then
            response.err = 'ERR_INVALID_JSON_FORMAT'
        else
            local dbconn, err = activity:new('ccsetter')
            if not dbconn then
                response.err = err
            else
                local res, cmd = nil, data['cmd']
                if cmd == 'add' then
                    res, err = dbconn:add(data.values)
                elseif cmd == 'del' then
                    res, err = dbconn:del(data.aid)
                elseif cmd == 'modify' then
                    res, err = dbconn:modify(data.aid, data.values)
                elseif cmd == 'set_priority' then
                    res, err = dbconn:set_priority(data.aid, data.priority)
                else
                    res, err = nil, "what info to edit?"
                end
                if not res then
                    response.err = err
                else
                    response.result = res
                    response.status = true
                end
                dbconn:keepalive()
            end
        end
    end
    ngx.status = ngx.HTTP_OK  
    ngx.say(cjson.encode(response))
    return ngx.exit(ngx.HTTP_OK)
end

local function entry()
    local request_method = ngx.req.get_method()
    local args, err = ngx.req.get_uri_args()

    ngx.say(cjson.encode({ method = request_method, uri=ngx.var.uri, args=args }))

    if 'GET' == request_method and '/activity/info' == ngx.var.uri then
        get_info(args)
    elseif 'POST' == request_method and '/activity/edit' == ngx.var.uri then
        edit_info(args)
    end
end

entry()
