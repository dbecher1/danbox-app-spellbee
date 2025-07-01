---@diagnostic disable: undefined-field

local Input = require('input')
local UI = require('ui.prelude')
local Globals = require('util.globals')

local lobby_private = {
    Elements = {},
}
local lobby = {}

-- Socket.IO uses a rate of 25s so hey here we are
local HEARTBEAT_RATE = 25 -- seconds

-- minimum users required to start 
local MIN_USERS = 3

function lobby.load()
    lobby_private.heartbeatTimer = 0
    lobby_private.debugText = UI.Text:new({
        content = 'LOBBY',
        alignX = UI.Align.X.RIGHT,
    })
    lobby_private.label = UI.Text:new({
        id = 'roomcode',
        shadowSize = 2,
        color = {1, 1, 0.2},
        size = UI.Text.Size.Large,
    })
    lobby_private.users = UI.FlexBox:new({
        direction = UI.FlexDirection.VERTICAL,
        gap = 2,
    })

    lobby_private.escape_text = UI.Text:new({
        id = 'escape-text',
        shadowSize = 2,
        content = 'Press Escape to Close Lobby',
        alignX = UI.Align.X.RIGHT,
    })

    table.insert(lobby_private.Elements,
        UI.FlexBox:new({
            x = 10,
            y = 10,
            direction = UI.FlexDirection.VERTICAL,
            elements = {
                UI.Text:new({
                    content = "ROOM CODE",
                    shadowSize = 2,
                    size = UI.Text.Size.Large,
                }),
                lobby_private.label,
                lobby_private.users,
                lobby_private.escape_text,
            }
        })
    )
end

function lobby.onEnter(code)
    print('lobby: onStart - room code: '..code)
    lobby_private.code = code
    lobby_private.label:setContent(code)
    local thread = love.thread.newThread('network/network_thread.lua')
    thread:start(Globals.GameID, code)
end

function lobby.onLeave()
    print('lobby: onLeave')
    love.thread.getChannel('to-network'):push('quit')
    lobby_private.code = nil
    lobby_private.label:setContent('')
    lobby_private.users:clear()
end

function lobby.keypressed()
    if Input.ESC then
        love.event.push('scenechange', 'MAIN_MENU')
    end
end

function lobby.update(dt)
    lobby_private.heartbeatTimer = lobby_private.heartbeatTimer + dt
    if lobby_private.heartbeatTimer >= HEARTBEAT_RATE then
        love.thread.getChannel('to-network'):push('heartbeat')
        lobby_private.heartbeatTimer = 0
    end
    local e = love.thread.getChannel('from-network'):pop()
    if e then
        if e.event == 'player_join' then
            print('Main thread received player join event')
            lobby_private.users:append_text(e.username, 'player-'..e.username)
        elseif e.event == 'player_leave' then
            print('Main thread received player leave event')
            lobby_private.users:remove('player-'..e.username)
        end
    end
end

function lobby.draw()
    if Debug then
        lobby_private.debugText:draw()
    end
    for _, elem in pairs(lobby_private.Elements) do
        elem:draw()
    end
end

return lobby