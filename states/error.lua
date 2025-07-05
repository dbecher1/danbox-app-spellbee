local UI = require('ui.prelude')
local Input = require('input')

local error_ = {}
local error = {}

function error.load()
    error_.message = UI.Text:new({
        id = 'error-text',
        color = UI.Color.red,
        size = UI.Text.Size.Large,
        shadow = UI.Text.Shadow.Medium,
        alignCentered = true,
    })
    error_.Elements = {
        UI.FlexBox:new({
            alignCentered = true,
            direction = UI.FlexDirection.VERTICAL,
            elements = {
                error_.message,
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

function error.onEnter(message)
    error_.message:setContent(message)
end

function error.keypressed()
    if Input.AnyKeyPressed() then
        love.event.push('scenechange', 'MAIN_MENU')
    end
end

function error.draw()
    for _, elem in pairs(error_.Elements) do
        elem:draw()
    end
end

return error