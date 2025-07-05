--local ffi = require('util.tts.engine.espeak')
local tts_engine = require('util.tts.engine')
local timer = require('love.timer')

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
    if data then
        if data == '%%TERMINATE%%' then
            break
        end
        speak(data)
    else
        -- check the callback channel
        local data_cb = love.thread.getChannel('to-tts-cb'):pop()
        if data_cb then
            speak(data_cb)
            love.thread.getChannel('from-tts-cb'):push(data_cb)
        else
            timer.sleep(0.01)
        end
    end
end
