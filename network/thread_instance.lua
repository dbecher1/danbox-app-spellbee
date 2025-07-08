
local instance = {}

local create_channel_name = require('network.channel_name')

---comment
---@param arg string
---@param type 'boolean'|'number'|'integer'|'string'|nil
local function cast_any(arg, type)
    if not type or type == 'string' then
        return arg
    end
    if type == 'boolean' then
        return string.lower(arg) == 'true'
    elseif type == 'number' then
        local n = tonumber(arg)
        assert(n)
        return n
    elseif type == 'integer' then
        local n = tonumber(arg)
        assert(n)
        return math.floor(n)
    end
    assert(false, 'Invalid type provided to cast_any. Valid types are: boolean, number, integer, string nil')
end

---Arg 1 of ... will always be the name of the thread. Arg 2 will always be a key value table, where the value will either be a string or a value (in idx 1) to be coerced into the type given in idx 2
---@param ... string | table<string, string | [any, string]>
---@return table
function instance:new(...)
    local inst = {}
    setmetatable(inst, self)
    self.__index = self

    local arg = {...}
    local name, args = arg[1], arg[2]
    assert(type(name) == "string" and type(args) == 'table')
    local send, rec = create_channel_name(name)
    inst.to_this = love.thread.getChannel(send)
    inst.from_this = love.thread.getChannel(rec)
    inst.custom_channels = {}
    inst.args = {}
    for k, v in args do
        if type(v) ~= 'string' then
            v = cast_any(v[1], v[2])
        end
        inst.args[k] = v
    end
    return inst
end

function instance:receive()
    
end

return instance