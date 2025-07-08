local websocket = require('network.websocket')
local json = require("util.json")
local Globals = require('util.globals')
local timer = require('love.timer')
local print_r = require('util.print_r').print_r

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

local client = websocket.new(Globals.HOST, Globals.PORT, Globals.PATH)

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
        -- print(e)
        if e == 'stop' then
            run = false
            client:close()
        elseif e == 'heartbeat' then
            -- print('Heartbeat sent')
            client:send(phx.msg())
        elseif e == 'gamestart' then
            client:send(phx.msg(phx.event, {
                name = 'gamestart'
            }))
        elseif type(e) == 'table' then
            if e.event == 'getwords' then
                local msg = phx.msg(phx.event, {
                    name = 'getwords',
                    payload = {
                        player_count = e.player_count,
                        grade = e.grade,
                    }
                })
                -- print(msg)
                client:send(msg)
            elseif e.event == 'turnstart' then
                local msg = phx.msg(phx.event, {
                    name = 'turnstart',
                    payload = {
                        player = e.player
                    }
                })
                client:send(msg)
            end
        end
    end
    timer.sleep(0.005)
end

print('network thread exited')
