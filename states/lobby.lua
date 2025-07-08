local Input = require('input')
local UI = require('ui.prelude')
local Globals = require('util.globals')
local tts = require('util.tts')
local Thread = require('network.thread')
local StateBase = require('states.state_base')

---@alias PlayerState {connected: boolean, score: integer}

---@class Lobby: StateBase
---@field private heartbeatTimer number
---@field private players table<string, PlayerState>
---@field private ready boolean
---@field private label Text
---@field private player_text FlexBox
---@field private escape_text Text
---@field private start_text Text
---@field private code string?
---@field private network_thread Thread
local Lobby = Inherit(StateBase)

-- Socket.IO uses a rate of 25s so hey here we are
local HEARTBEAT_RATE = 25 -- seconds

-- minimum players required to start 
-- will be 3 in the future, 1 now for dev
local MINIMUM_PLAYERS = 0

function Lobby:new()
    local lobby = StateBase.new(self)
    -- some stateful variables first
    lobby.heartbeatTimer = 0
    -- lobby_private.player_count = 0
    lobby.players = {}
    lobby.ready = true -- SET THIS BACK TO FALSE

    lobby.label = UI.Text:new({
        id = 'roomcode',
        shadow = UI.Text.Shadow.Medium,
        color = {1, 1, 0.2},
        size = UI.Text.Size.Large,
    })

    lobby.player_text = UI.FlexBox:new({
        direction = UI.FlexDirection.VERTICAL,
        gap = 2,
    })

    lobby.escape_text = UI.Text:new({
        id = 'escape-text',
        shadow = UI.Text.Shadow.Small,
        content = 'Press Escape to Close Lobby',
        alignX = UI.Align.X.RIGHT,
        size = UI.Text.Size.Small
    })

     lobby.start_text = UI.Text:new({
        id = 'start-text',
        shadow = UI.Text.Shadow.Medium,
        content = 'Press Enter to Start',
        alignCentered = true,
        size = UI.Text.Size.Large,
        active = false,
    })

    table.insert(lobby.Elements,
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
                lobby.label,
                lobby.player_text,
            }
        })
    )

    table.insert(lobby.Elements, lobby.escape_text)
    table.insert(lobby.Elements, lobby.start_text)
    lobby.network_thread = Thread:new({
        name = 'network',
        path = 'network/network_thread.lua'
    })
    return lobby
end

---@param code string
function Lobby:onEnter(code)
    self.code = code
    self.label:setContent(code)
    self.network_thread:start(Globals.GameID, code)

    tts.speak_many('Welcome to the game')
end

function Lobby:onLeave(next_state)
    -- if going back to the menu, terminate the network thread
    -- obviously if we advance in the game we want it to persist
    if next_state == 'MAIN_MENU' then
        self.network_thread:stop()
    end

    self.code = nil
    self.label:setContent('')
    self.player_text:clear()
    self.players = {}
    -- lobby_private.ready = false -- TODO: RESET ME
end

function Lobby:keypressed()
    if tts.is_speaking() then return end
    if Input.ESC() then
        PushEvent('scenechange', 'MAIN_MENU', 'MAIN_MENU')
    end
    if Input.ACTION() and self.ready then
        PushEvent('scenechange', 'COUNTDOWN', self.players, self.network_thread)
    end
end

function Lobby:update(dt)
    self.heartbeatTimer = self.heartbeatTimer + dt
    local last_ready_state = self.ready

    if self.heartbeatTimer >= HEARTBEAT_RATE then
        --love.thread.getChannel('to-network'):push('heartbeat')
        self.network_thread:send('heartbeat')
        self.heartbeatTimer = 0
    end

    local e = self.network_thread:receive()

    if e then
        if e.event == 'player_join' then
            print('Main thread received player join event')

            self.player_text:append_text(e.username, 'player-'..e.username)
            self.players[e.username] = {
                connected = true,
                score = 0,
            }
            --lobby_private.player_count = lobby_private.player_count + 1

            if #self.players >= MINIMUM_PLAYERS then
                self.ready = true
            end

            tts.speak('We have a new player in the lobby. Give it up for ' .. e.username .. '!')

        elseif e.event == 'player_leave' then
            print('Main thread received player leave event')

            self.player_text:remove('player-'..e.username)
            self.players[e.username] = nil
            -- lobby_private.player_count = lobby_private.player_count - 1
            if #self.players < MINIMUM_PLAYERS then
                self.ready = false
            end

            tts.speak('Farewell, ' .. e.username)
        end
    end

    if last_ready_state ~= self.ready then
        self.start_text:set_active(self.ready)
    end
end

return Lobby