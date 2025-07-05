
local util = {}
local uuid = require('util.uuid')
util.print_r = require('util.print_r').print_r
util.uuid = uuid.uuid

function util.inherit(parent)
    return setmetatable({}, {__index = parent})
end

return util