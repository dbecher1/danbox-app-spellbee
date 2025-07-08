local Input = require('input')
local Globals = require('util.globals')
local UI = require('ui.prelude')
local json = require('util.json')
local Thread = require('network.thread')
local StateBase = require('states.state_base')

---@class Loading: StateBase
---@field private text Text
local Loading = Inherit(StateBase)

function Loading:new()
    local loading = StateBase.new(self)
    loading.text = UI.Text:new({
        content = 'LOADING...'
    })
    return loading
end
function Loading:onEnter()
    self.req_thread = Thread:new({
        name = 'request_code',
        path = 'network/request_code.lua'
    }):start(Globals.GameID)
end

function Loading:onLeave()
    if self.req_thread:is_running() then
        self.req_thread:stop()
    end
end

function Loading:keypressed()
    if Input.ESC() then
        PushEvent('scenechange', 'MAIN_MENU')
    end
end

function Loading:update(dt)
    local result = self.req_thread:receive()
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

function Loading:draw()
    self.text:draw()
end

return Loading