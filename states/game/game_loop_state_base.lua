local StateBase = require('states.state_base')

---@alias GameLoopEvent 'next'

---@class GameLoopStateBase: StateBase
---@field private Event GameLoopEvent[]
local state = Inherit(StateBase)

function state:new()
    local s = StateBase.new(self)
    s.Event = {}
    return s
end

---@param e GameLoopEvent
---@protected
function state:push_event(e)
    table.insert(self.Event, e)
end

---@return string?
function state:poll_event()
    if #self.Event == 0 then return nil end
    return table.remove(self.Event)
end

---@param grade Grades
---@protected
function state.gen_grade_str(grade)
    return tostring(grade) .. 'th grade'
end

return state