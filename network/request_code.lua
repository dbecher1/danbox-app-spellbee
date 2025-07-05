local http = require('socket.http')
local ltn12 = require('ltn12')
local timer = require('love.timer')

local url_dev = 'http://localhost:4000/api/generate_code'

local game_id = ...

local request_body = '{"id": "' .. game_id .. '"}'
local response_body = {}

local retry_wait = 1 -- in seconds, the amount of time to wait for a retry when a request fails
local retry_count = 5 -- the max amount of requests to try to the server, will timeout when this number is hit
local request_count = 0

local function try_request()
    return http.request({
        url = url_dev,
        method = 'POST',
        headers = {
            ["Content-Type"] = 'application/json',
            ["Content-Length"] = tostring(#request_body),
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body)
    })
end

local success, status

while request_count < retry_count do
    local e = love.thread.getChannel('to-request_code'):pop()
    if e then
        if e == 'stop' then
            return
        end
    end
    success, status = try_request()
    if success then break end
    request_count = request_count + 1
    print('Code request failed. Trying ' .. tostring(retry_count - request_count) .. ' more times')
    timer.sleep(retry_wait)
end

if success then
    love.thread.getChannel('from-request_code'):push({
        body = response_body[1],
        status = status
    })
else
    love.thread.getChannel('from-request_code'):push({
        status = 'ERROR'
    })
end


