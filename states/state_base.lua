
---@class StateBase
---@field protected Elements Component[]
local state = {
    Elements = {}
}

function state:new()
    local s = {}
    setmetatable(s, self)
    self.__index = self
    return s
end

function state:load()

end

function state:onEnter()

end

function state:onLeave()

end

function state:keypressed()

end

---@param dt number
function state:update(dt)

end

function state:draw()
    for _, elem in pairs(self.Elements) do
---@diagnostic disable-next-line: undefined-field
        elem:draw()
    end
end

return state