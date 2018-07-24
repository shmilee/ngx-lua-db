-- Copyright (c) 2018 shmilee

local _M = { _VERSION = '0.01' }

_M.MYSQL = {
    HOST = "127.0.0.1",
    PORT = 3306,
    DATABASE = "cultural_centre",
    ACT_TABLE = 'activities',
    SET_USER = "ccsetter",
    SET_PASSWORD = "setter_pass",
    GET_USER = "ccgetter",
    GET_PASSWORD = "getter_pass",
    DEFAULT_CHARSET = "utf8",
    MAX_PACKET_SIZE = 1024 * 1024,
    TIMEOUT = 2000, -- 2 sec
}

_M.REDIS = {
    HOST = "127.0.0.1",
    PORT = 6379,
    TIMEOUT = 1000,
}

return _M
