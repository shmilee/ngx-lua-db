-- @Copyright (c) 2018 shmilee
-- @classmod cclua.const

local _M = { _VERSION = '0.1.0' }

_M.MYSQL = {
    HOST = "127.0.0.1",
    PORT = 3306,
    DATABASE = "cultural_centre",
    DEFAULT_CHARSET = "utf8",
    MAX_PACKET_SIZE = 1024 * 1024,
    TIMEOUT = 2000, -- 2 sec
}

_M.REDIS = {
    HOST = "127.0.0.1",
    PORT = 6379,
    TIMEOUT = 1000,
}

_M.USER = {
    ccadmin = { passwd = "ccadmin_pass" },
    ccsetter = { passwd = "ccsetter_pass" },
    ccgetter = { passwd = "ccgetter_pass" },
}

return _M
