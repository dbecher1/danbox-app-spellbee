local StateBase = require('states.state_base')
local UI = require('ui.prelude')

-- I use this as a canvas for when I'm working on things

---@class Test: StateBase
---@field env test_envs
local Test = Inherit(StateBase)

---@enum test_envs
local test_envs = {
    scoreboard = 1,
}

local function scoreboard()
    local f = UI.Grid:new({
        y = -100,
        border = 1,
        alignCentered = true,
        text_color = UI.Color.black,
        fill_color = UI.Color.yellow,
        rowHeight = 50
    }, {'Player', 'Score'},
        {200, 120},
        {
            {'Brian', '69'},
            {'Chad', '420'}
        }
    )
    f:append_row()

    f:set_cell(2, 2, 0)
    f:set_row(1, {'Mom', '1'})

    f:set_row(3, {'Beautiful', '012'})

    return f
end

function Test:new()
    local t = StateBase.new(self)
    table.insert(t.Elements, test_envs.scoreboard, scoreboard())
    t.env = test_envs.scoreboard
    return t
end

function Test:update(dt) end

function Test:draw()
    self.Elements[self.env]:draw()
end

return Test