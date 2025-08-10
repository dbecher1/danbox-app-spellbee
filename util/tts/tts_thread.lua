local tts_engine = require('util.tts.engine')
local timer = require('love.timer')

local messages = {}

local function speak(data)
    if type(data) ~= 'string' then
        data = tostring(data)
    end
    -- the channel is used to query if the tts is currently speaking
    love.thread.getChannel('from-tts'):push(true)
    tts_engine.speak(data)
    -- sleep for 1/3 a second after speaking
    -- this gives a slight break between multiple lines
    timer.sleep(0.34)
    love.thread.getChannel('from-tts'):push(false)
end

while true do
    local data = love.thread.getChannel('to-tts'):pop()
    while data do
        data.cb = false
        table.insert(messages, data)
        data = love.thread.getChannel('to-tts'):pop()
    end
    local data_cb = love.thread.getChannel('to-tts-cb'):pop()
    while data_cb do
        --speak(data_cb)
        data_cb.cb = true
        table.insert(messages, data_cb)
        data_cb = love.thread.getChannel('to-tts-cb'):pop()
    end
    if #messages > 0 then
        table.sort(messages, function(lhs, rhs) return lhs.n > rhs.n end)
        local d = table.remove(messages)
        repeat
            speak(d.data)
            if d.cb then
                love.thread.getChannel('from-tts-cb'):push(d.data)
            end
            d = table.remove(messages)
        until d == nil
    end
    -- check the callback channel
    timer.sleep(0.01)
    
    
end
