local UI = require('ui.prelude')
local tts = require('util.tts')
local Thread = require('network.thread')
local print_r = require('util.print_r').print_r

-- The countdown is cute and silly, but this is also when we populate the word bank

local grade = 5 -- this may be changed in the future, or maybe be made customizable

local countdown_private = {
    Elements = {},
}
local countdown = {}

local function transition()
    if countdown_private.words == nil then
        love.event.push('scenechange', 'ERROR', 'Network error')
        return
    end
    local gamestate = {
        players = countdown_private.players,
        network_thread = countdown_private.network_thread,
        words = countdown_private.words
    }
    love.event.push('scenechange', 'GAMEPLAY_LOOP', gamestate)
end

function countdown_private.update_counter()
    if countdown_private.number > 0 then
        countdown_private.number_text:setContent(countdown_private.number)
        tts.speak(countdown_private.number)
    else
        local msg = 'Let us play the game'
        countdown_private.number_text:setContent(msg)
        tts.speak_then(msg, transition)
    end
end

function countdown.load()
    countdown_private.number_text = UI.Text:new({
        id = 'countdown-text',
        shadow = UI.Text.Shadow.Large,
        alignCentered = true,
        size = UI.Text.Size.Large,
        color = {1, 0, 0}
    })
    table.insert(countdown_private.Elements, countdown_private.number_text)

    countdown_private.number = 3
    countdown_private.counter = 0
end

function countdown.onEnter(players, network_thread)
    -- print_r(network_thread)
    countdown_private.players = players
    countdown_private.network_thread = Thread:rehydrate(network_thread)
    countdown_private.network_thread:send({
        event = 'getwords',
        --player_count = #players,
        player_count = 3,
        grade = grade,
    })
    countdown_private.update_counter()
end

function countdown.update(dt)
    if countdown_private.number > 0 then
        countdown_private.counter = countdown_private.counter + dt
        if countdown_private.counter >= 1 then
            countdown_private.counter = 0
            countdown_private.number = countdown_private.number - 1
            countdown_private.update_counter()
        end
    end
    local e = countdown_private.network_thread:receive()
    if e then
        if e.event == 'words' then
            countdown_private.words = e.words
        end
    end
end

function countdown.draw()
    for _, elem in pairs(countdown_private.Elements) do
        elem:draw()
    end
end

return countdown