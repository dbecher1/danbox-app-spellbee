local UI = require('ui.prelude')
local tts = require('util.tts')

local state = {}
local private = {
    Elements = {},
    Event = {}
}

function state.load()
    
end

function state.onEnter(gamestate)
    private.gamestate = gamestate
end

function state.onLeave()

end

function state.keypressed()

end

function state.update(dt)

end

function state.poll()
    if #private.Event == 0 then return nil end
    return table.remove(private.Event, 1)
end

function state.draw()
    for _, elem in pairs(private.Elements) do
        elem:draw()
    end
end

return state