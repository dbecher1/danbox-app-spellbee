
Uuid = require('util.uuid').uuid
Print_r = require('util.print_r').print_r
Input = require('input')

function Inherit(parent)
    return setmetatable({}, {__index = parent})
end
