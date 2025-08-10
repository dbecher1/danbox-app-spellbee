local websocket = require('network.websocket')
local json = require("util.json")
local timer = require('love.timer')
require('util.globals')

local id, roomcode = ...
local message = 0

local phx = {
    join = 1,
    leave = 2,
    heartbeat = 3,
    event = 4,
}

function phx.payloadFormat(payload)
    if #payload == 0 then
        --return nil
    end
    local out = '{'
    local comma = false
    for k, v in pairs(payload) do
        if not comma then
            comma = true
        else
            out = out..','
        end
        out = out..'"'..k..'":"'..v..'"'
    end
    out = out..'}'
    return out
end

-- If no args, heartbeat
function phx.msg(e, args)
    e = e or phx.heartbeat
    args = args or {}
    local out = {
        msg = '"'..message..'"',
        topic = '"room:'..roomcode..'"'
    }
    if e == phx.join then
        out.joinref = '"'..id..'"'
        out.event = '"phx_join"'
        out.payload = phx.payloadFormat(args) or '{}'
    elseif e == phx.leave then
        out.joinref = 'null'
        out.event = '"leave"'
        out.payload = "{}"
    elseif e == phx.event then
        out.joinref = 'null'
        out.event = '"'..args.name..'"'
        --out.payload = '{}'
        out.payload = phx.payloadFormat(args.payload or {}) or '{}'
    else
        out.joinref = 'null'
        out.topic = '"phoenix"'
        out.event = '"heartbeat"'
        out.payload = '{}'
    end
    message = message + 1
    local outStr = '['..out.joinref..', '..out.msg..', '..out.topic..', '..out.event..', '..out.payload..']'
    -- print(outStr)
    return outStr
end

local client = websocket.new(WEB_HOST, WEB_PORT, WEB_PATH)

function client:onmessage(msg)
    -- print_r(msg)
    local decode = json.decode(msg)
    local e = decode[4]
    if e == 'player_join' then
        local username = decode[5].username
        love.thread.getChannel('from-network'):push({
            event = 'player_join',
            username = username
        })
    elseif e == 'player_leave' then
        local username = decode[5].username
        love.thread.getChannel('from-network'):push({
            event = 'player_leave',
            username = username
        })
    elseif e == 'words' then
        local words = decode[5].words
        love.thread.getChannel('from-network'):push({
            event = 'words',
            words = words
        })
    elseif e == 'guess' then
        -- print(decode[5].guess)
        love.thread.getChannel('from-network'):push({
            event = 'guess',
            guess = decode[5].guess
        })
    else
        -- print('Unhandled message: ', msg)
    end
end

function client:onopen()
    -- todo: handle response!
    self:send(phx.msg(phx.join))
end

function client:onerror(error)
    print(error)
end

function client:onclose(code, reason)
    self:send(phx.msg(phx.leave))
    print('close code: '..code..", reason: "..reason)
end

local run = true

print('starting network thread')

while run do
    client:update()
    local e = love.thread.getChannel('to-network'):pop()
    if e then
        local msg

        if e == 'stop' then
            run = false
            client:close()

        elseif e == 'heartbeat' then

            msg = phx.msg()

        elseif e == 'gamestart' then
            msg = phx.msg(phx.event, {
                name = 'gamestart'
            })

        elseif e == 'ready' then
            msg = phx.msg(phx.event, {
                name = 'ready'
            })

        elseif e == 'notready' then
            msg = phx.msg(phx.event, {
                name = 'notready'
            })

        elseif type(e) == 'table' then
            if e.event == 'getwords' then
                msg = phx.msg(phx.event, {
                    name = 'getwords',
                    payload = {
                        player_count = e.player_count,
                        grade = e.grade,
                    }
                })

            elseif e.event == 'turnstart' then
                msg = phx.msg(phx.event, {
                    name = 'turnstart',
                    payload = {
                        player = e.player
                    }
                })

            elseif e.event == 'roundstart' then
                msg = phx.msg(phx.event, {
                    name = 'roundstart',
                    payload = {
                        grade = e.grade
                    }
                })
            end
        end
        if msg then
            client:send(msg)
        end
    end
    timer.sleep(0.005)
end

print('network thread exited')
