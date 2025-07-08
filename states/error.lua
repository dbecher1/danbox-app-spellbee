local UI = require('ui.prelude')
local Input = require('input')
local StateBase = require('states.state_base')

---@class Error: StateBase
---@field private message Text
local Error = Inherit(StateBase)

function Error:new()
    local error = StateBase.new(self)
    error.message = UI.Text:new({
        id = 'error-text',
        color = UI.Color.red,
        size = UI.Text.Size.Large,
        shadow = UI.Text.Shadow.Medium,
        alignCentered = true,
    })
    error.Elements = {
        UI.FlexBox:new({
            alignCentered = true,
            direction = UI.FlexDirection.VERTICAL,
            elements = {
                error.message,
                UI.Text:new({
                    content = 'Press any key to exit to the main menu',
                    size = UI.Text.Size.Small,
                    shadow = UI.Text.Shadow.Small,
                    alignCentered = true,
                })
            }
        })
    }
end

function Error:onEnter(message)
    self.message:setContent(message)
end

function Error:keypressed()
    if Input.AnyKeyPressed() then
        PushEvent('scenechange', 'MAIN_MENU')
    end
end

return Error