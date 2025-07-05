local UI = require('ui.prelude')

local private = {
    Elements = {},
}
local state = {}

function state.load()

end

function state.onEnter()

end

function state.onLeave()

end

function state.keypressed()

end

function state.update(dt)

end

function state.draw()
    for _, elem in pairs(private.Elements) do
        elem:draw()
    end
end

return state