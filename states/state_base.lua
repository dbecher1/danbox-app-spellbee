
---@class StateBase
---@field protected Elements Component[]
---@field protected debugText Text?
local state = {}

function state:new()
    local s = {}
    setmetatable(s, self)
    self.__index = self
    s.Elements = {}
    s.debugText = nil

    return s
end

function state:onEnter(arg1, arg2, arg3) end

function state:onLeave(arg1, arg2, arg3) end

function state:keypressed() end

function state:keyreleased() end

---@param dt number
function state:update(dt) end

function state:draw()
    for _, elem in pairs(self.Elements) do
        elem:draw()
    end
    if state.debugText then
        state.debugText:draw()
    end
end

return state