local http = require('socket.http')
local ltn12 = require('ltn12')

local url_dev = 'http://localhost:4000/api/generate_code'

local game_id = ...

local request_body = '{"id": "' .. game_id .. '"}'
local response_body = {}

local _, status = http.request({
    url = url_dev,
    method = 'POST',
    headers = {
        ["Content-Type"] = 'application/json',
        ["Content-Length"] = tostring(#request_body),
    },
    source = ltn12.source.string(request_body),
    sink = ltn12.sink.table(response_body)
})

love.thread.getChannel('generate_code'):push({
    body = response_body[1],
    status = status
})

