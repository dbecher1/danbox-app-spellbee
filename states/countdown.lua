local UI = require('ui.prelude')
local tts = require('util.tts')
local Thread = require('network.thread')
local StateBase = require('states.state_base')

-- The countdown is cute and silly, but this is also when we populate the word bank

local grade = 5 -- this may be changed in the future, or maybe be made customizable

---@class Countdown: StateBase
---@field private number_text Text
---@field private number integer
---@field private counter number
---@field private network_thread Thread?
---@field private words table?
local Countdown = Inherit(StateBase)

---@alias Grades 1|2|3|4|5|6|7|8|9|10|11|12
---@alias WordBank table<Grades, string[]>

---@private
function Countdown:transition()
    if self.words == nil then
        PushEvent('scenechange', 'ERROR', 'Network error')
        return
    end
    local gamestate = {
        players = self.players,
        network_thread = self.network_thread,
        words = self.words
    }
    self.network_thread:send('gamestart')
    PushEvent('scenechange', 'GAMEPLAY_LOOP', gamestate)
end

---@private
function Countdown:update_counter()
    if self.number > 0 then
        self.number_text:setContent(self.number)
        tts.speak(self.number)
    else
        local msg = 'Let us play the game'
        self.number_text:setContent(msg)
        tts.speak_then(msg, function() self:transition() end)
    end
end

function Countdown:new()
    local countdown = StateBase.new(self)
    countdown.number_text = UI.Text:new({
        id = 'countdown-text',
        shadow = UI.Text.Shadow.Large,
        alignCentered = true,
        size = UI.Text.Size.Large,
        color = {1, 0, 0}
    })
    table.insert(countdown.Elements, countdown.number_text)

    countdown.number = 3
    countdown.counter = 0
    countdown.players = {}
    self.network_thread = nil
    return countdown
end

---
---@param players table<string, PlayerState>
---@param network_thread Thread
function Countdown:onEnter(players, network_thread)
    -- print_r(network_thread)
    self.players = players
    self.network_thread = Thread:rehydrate(network_thread)
    self.network_thread:send({
        event = 'getwords',
        --player_count = #players,
        player_count = 3,
        grade = grade,
    })
    self:update_counter()
end

function Countdown:update(dt)
    if self.number > 0 then
        self.counter = self.counter + dt
        if self.counter >= 1 then
            self.counter = 0
            self.number = self.number - 1
            self:update_counter()
        end
    end
    ---@type {event: string, words: WordBank}
    local e = self.network_thread:receive()
    if e then
        if e.event == 'words' then
            self.words = e.words
        end
    end
end

return Countdown