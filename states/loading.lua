local loading_private = {
    Elements = {},
}
local loading = {}
local Input = require('input')
local Globals = require('util.globals')
local UI = require('ui.prelude')
local json = require('util.json')
local Thread = require('network.thread')

function loading.load()
    loading_private.text = UI.Text:new({
        content = 'LOADING...'
    })
end
function loading.onEnter()
    loading_private.req_thread = Thread:new({
        name = 'request_code',
        path = 'network/request_code.lua'
    }):start(Globals.GameID)
end

function loading.onLeave()
    if loading_private.req_thread:is_running() then
        loading_private.req_thread:stop()
    end
end

function loading.keypressed()
    if Input.ESC() then
        PushEvent('scenechange', 'MAIN_MENU')
    end
end

function loading.update(dt)
    local result = loading_private.req_thread:receive()
    if result then
        if result.status == 'ERROR' then
            -- server error
            --loading_private.error_text:activate()
            PushEvent('scenechange', 'ERROR', 'Server timeout')
        else
            local body = json.decode(result.body)
            PushEvent('scenechange', 'LOBBY', body.code)
        end
    end
end

function loading.draw()
    loading_private.text:draw()
end

return loading