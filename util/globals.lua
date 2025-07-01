-- variables defined on a global level in the application are defined here so as to not pollute the global table

local Util = require('util.mod')

local env = {
    Debug = true,

    HOST = "127.0.0.1",
    PORT = 4000,
    PATH = '/socket/websocket?vsn=2.0.0',
}

function env.load()
    env.BackBuffer = love.graphics.newCanvas()
    env.GameID = Util.uuid()
end

return env