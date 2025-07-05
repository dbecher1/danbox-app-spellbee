
local Thread = {}

local function create_custom_channel_name(name, channel)
    local send = 'to-' .. name .. '-' .. channel
    local rec = 'from-' .. name .. '-' .. channel
    return send, rec
end

function Thread:new(t)
    t = t or {}
    setmetatable(t, self)
    self.__index = self

    assert(t.name, 'Thread must be created with a name field')
    assert(t.path, 'Thread must be created with a valid path field')

    t.inner_state = love.thread.newThread(t.path)
    t.send_channel = love.thread.getChannel('to-'..t.name)
    t.receive_channel = love.thread.getChannel('from-'..t.name)
    t.callbacks = {}

    return t
end

function Thread:rehydrate(t)
    setmetatable(t, self)
    self.__index = self
    return t
end

-- Returns self for the purpose of chaining
function Thread:start(arg1, arg2, ...)
--function Thread:start(...)
    self.inner_state:start(arg1, arg2, arg)
    --self.inner_state:start(unpack(arg))
    return self
end

function Thread:send(payload)
    self.send_channel:push(payload)
    return self
end

function Thread:send_on(channel, payload)
    local send, _ = create_custom_channel_name(self.name, channel)
    self[send]:push(payload)
end

function Thread:stop()
    self.send_channel:push('stop')
end

function Thread:receive()
    return self.receive_channel:pop()
end

function Thread:receive_on(channel, payload)
    local _, rec = create_custom_channel_name(self.name, channel)
    return self[rec]:pop()
end

function Thread:is_running()
    return self.inner_state:isRunning()
end

---@param channel string
function Thread:new_channel(channel)
    local send, rec = create_custom_channel_name(self.name, channel)
    self[send] = love.thread.getChannel(send)
    self[rec] = love.thread.getChannel(rec)
    --self:send({event = 'INIT-CHANNEL',send = send,rec = rec,})
end

return Thread