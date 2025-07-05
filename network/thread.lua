
---@class Thread A wrapper class for a love thread
---@field private name string The name of the thread - used to create the channel names
---@field private path string The path to the .lua file for the thread code
---@field private inner_state love.Thread
---@field private send_channel love.Channel The channel that sends to this thread - user perspective
---@field private receive_channel love.Channel The channel that this thread sends from - user perspective
---@field private custom_channels table<string, love.Channel>
local Thread = {}

---Given a thread name and channel name, creates the names for a new custom channel.
---@param name string
---@param channel string
---@return string
---@return string
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

    return t
end

---Channels and events in love strip metatables - this rebuilds the metatable
---@param t table
---@return Thread
function Thread:rehydrate(t)
    setmetatable(t, self)
    self.__index = self
    return t
end

---Starts the inner state of this thread. Returns self for the purpose of chaining.
---@param ... any
---@return Thread
function Thread:start(...)
    self.inner_state:start(...)
    return self
end

--- Creates a new custom channel
---@param channel string | [string, string] Either the name of the channel to create, or a tuple of the send/rec channel names
function Thread:new_channel(channel)
    local send, rec
    if type(channel) == 'string' then
        send, rec = create_custom_channel_name(self.name, channel)
    else
        send, rec = channel[1], channel[2]
    end
    self.custom_channels[send] = love.thread.getChannel(send)
    self.custom_channels[rec] = love.thread.getChannel(rec)
    --self:send({event = 'INIT-CHANNEL',send = send,rec = rec,})
end

---Sends to a custom, named channel on thread. Returns self for the purpose of chaining
---@param payload string
---@param channel string
---@return Thread
---@private
function Thread:send_on(payload, channel)
    local send, rec = create_custom_channel_name(self.name, channel)
    if not self.custom_channels[send] then
        self:new_channel({send, rec})
    end
    self.custom_channels[send]:push(payload)
    return self
end

---Sends to this thread, or a custom thread if name is provided. Returns self for the purpose of chaining
---@param payload any
---@param channel string?
---@return Thread
function Thread:send(payload, channel)
    if channel then
        return self:send_on(payload, channel)
    end
    self.send_channel:push(payload)
    return self
end

---@private
function Thread:receive_on(channel)
    local send, rec = create_custom_channel_name(self.name, channel)
    if not self[rec] then
        self:new_channel({send, rec})
    end
    return self[rec]:pop()
end

---Polls either the main thread channel or, if provided, a custom channel for a message
---@param channel string?
---@return any
function Thread:receive(channel)
    if channel then
        return self:receive_on(channel)
    end
    return self.receive_channel:pop()
end

---Stops the main process of the thread
function Thread:stop(channel)
    self.send_channel:push('stop')
end

---Returns if the thread is currently running
---@return boolean
function Thread:is_running()
    return self.inner_state:isRunning()
end

return Thread