---Given a thread name and (optional) channel name, creates the names for a new channel, either default or custom depending of if the channel arg is given.
---@param name string
---@param channel string?
---@return string
---@return string
local function create_channel_name(name, channel)
    local send = 'to-' .. name
    local rec = 'from-' .. name
    if channel then
        send = send .. '-' .. channel
        rec = rec .. '-' .. channel
    end
    return send, rec
end

return create_channel_name