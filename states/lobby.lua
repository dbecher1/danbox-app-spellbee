---@diagnostic disable: undefined-field

local Input = require('input')
local UI = require('ui.prelude')
local Globals = require('util.globals')
local tts = require('util.tts')
local Thread = require('network.thread')

local lobby_private = {
    Elements = {},
}
local lobby = {}

-- Socket.IO uses a rate of 25s so hey here we are
local HEARTBEAT_RATE = 25 -- seconds

-- minimum players required to start 
-- will be 3 in the future, 1 now for dev
local MINIMUM_PLAYERS = 0

function lobby.load()
    -- some stateful variables first
    lobby_private.heartbeatTimer = 0
    -- lobby_private.player_count = 0
    lobby_private.players = {}
    lobby_private.ready = true -- SET THIS BACK TO FALSE

    lobby_private.debugText = UI.Text:new({
        content = 'LOBBY',
        alignX = UI.Align.X.RIGHT,
    })

    lobby_private.label = UI.Text:new({
        id = 'roomcode',
        shadow = UI.Text.Shadow.Medium,
        color = {1, 1, 0.2},
        size = UI.Text.Size.Large,
    })

    lobby_private.player_text = UI.FlexBox:new({
        direction = UI.FlexDirection.VERTICAL,
        gap = 2,
    })

    lobby_private.escape_text = UI.Text:new({
        id = 'escape-text',
        shadow = UI.Text.Shadow.Small,
        content = 'Press Escape to Close Lobby',
        alignX = UI.Align.X.RIGHT,
        size = UI.Text.Size.Small
    })

     lobby_private.start_text = UI.Text:new({
        id = 'start-text',
        shadow = UI.Text.Shadow.Medium,
        content = 'Press Enter to Start',
        alignCentered = true,
        size = UI.Text.Size.Large,
        active = false,
    })

    table.insert(lobby_private.Elements,
        UI.FlexBox:new({
            x = 10,
            y = 10,
            direction = UI.FlexDirection.VERTICAL,
            elements = {
                UI.Text:new({
                    content = "ROOM CODE",
                    shadow = UI.Text.Shadow.Medium,
                    size = UI.Text.Size.Large,
                }),
                lobby_private.label,
                lobby_private.player_text,
            }
        })
    )

    table.insert(lobby_private.Elements, lobby_private.escape_text)
    table.insert(lobby_private.Elements, lobby_private.start_text)
end

function lobby.onEnter(code)
    lobby_private.code = code
    lobby_private.label:setContent(code)
    lobby_private.network_thread = Thread:new({
        name = 'network',
        path = 'network/network_thread.lua'
    }):start(Globals.GameID, code)

    tts.speak_many('Welcome to the game', 'I love you')
end

function lobby.onLeave(next_state)
    -- if going back to the menu, terminate the network thread
    -- obviously if we advance in the game we want it to persist
    if next_state == 'MAIN_MENU' then
        lobby_private.network_thread:stop()
    end

    lobby_private.code = nil
    lobby_private.label:setContent('')
    lobby_private.player_text:clear()
    lobby_private.players = {}
    -- lobby_private.ready = false
end

function lobby.keypressed()
    if tts.is_speaking() then return end
    if Input.ESC() then
        PushEvent('scenechange', 'MAIN_MENU', 'MAIN_MENU')
    end
    if Input.ACTION() and lobby_private.ready then
        PushEvent('scenechange', 'COUNTDOWN', lobby_private.players, lobby_private.network_thread)
    end
end

function lobby.update(dt)
    lobby_private.heartbeatTimer = lobby_private.heartbeatTimer + dt
    local last_ready_state = lobby_private.ready

    if lobby_private.heartbeatTimer >= HEARTBEAT_RATE then
        --love.thread.getChannel('to-network'):push('heartbeat')
        lobby_private.network_thread:send('heartbeat')
        lobby_private.heartbeatTimer = 0
    end

    local e = lobby_private.network_thread:receive()

    if e then
        if e.event == 'player_join' then
            print('Main thread received player join event')

            lobby_private.player_text:append_text(e.username, 'player-'..e.username)
            lobby_private.players[e.username] = {
                connected = true,
                score = 0,
            }
            --lobby_private.player_count = lobby_private.player_count + 1

            if #lobby_private.players >= MINIMUM_PLAYERS then
                lobby_private.ready = true
            end

            tts.speak('We have a new player in the lobby. Give it up for ' .. e.username .. '!')

        elseif e.event == 'player_leave' then
            print('Main thread received player leave event')

            lobby_private.player_text:remove('player-'..e.username)
            lobby_private.players[e.username] = nil
            -- lobby_private.player_count = lobby_private.player_count - 1
            if #lobby_private.players < MINIMUM_PLAYERS then
                lobby_private.ready = false
            end

            tts.speak('Farewell, ' .. e.username)
        end
    end
    if last_ready_state ~= lobby_private.ready then
        lobby_private.start_text:set_active(lobby_private.ready)
    end
end

function lobby.draw()
    if Globals.Debug then
        lobby_private.debugText:draw()
    end
    for _, elem in pairs(lobby_private.Elements) do
        elem:draw()
    end
end

return lobby