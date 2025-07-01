local loading_private = {
    Elements = {},
}
local loading = {}
local Input = require('input')
local Globals = require('util.globals')
local UI = require('ui.prelude')
local json = require('util.json')

function loading.load()
    loading_private.debugText = UI.Text:new({
        content = 'LOADING...'
    })
end

function loading.onEnter()
    print('loading: onEnter')
    local t = love.thread.newThread('network/request_code.lua')
    t:start(Globals.GameID)
end

function loading.onLeave()
    print('loading: onLeave')
end

function loading.keypressed()

end

function loading.update(dt)
    local result = love.thread.getChannel('generate_code'):pop()
    if result then
        -- do something to handle server error here!!
        local body = json.decode(result.body)
        -- Util.print_r(body)
        -- print('Code: ' .. body.code)
        -- print('Status: ' .. result.status)
        love.event.push('scenechange', 'LOBBY', body.code)
    end
end

function loading.draw()
    if Globals.Debug then
        loading_private.debugText:draw()
    end
end

return loading