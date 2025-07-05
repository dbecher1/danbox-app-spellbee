
local ThreadInstance = {}

function ThreadInstance:new(...)
    local t = {}
    local arg = {...}
    setmetatable(t, self)
    self.__index = self

    assert(arg.name, 'Thread instance must be created with a name field')

    return t
end

return ThreadInstance