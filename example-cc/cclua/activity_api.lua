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
local function edit_info(args)

--    add(values)
--61:function _M:del(aid)
  --  104:function _M:modify(aid, values)
--133:function _M:set_priority(aid, priority)
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
