local StateBase = require('states.state_base')

---@class Menu: StateBase
---@field private debugText Text
local Menu = Inherit(StateBase)

local UI = require('ui.prelude')

function Menu:new()
    local menu = StateBase.new(self)
    menu.debugText = UI.Text:new{
        content = 'MENU'
    }
    local titleText = UI.Text:new({
        content = 'BepisBee',
        alignX = UI.Align.X.CENTER,
        y = 50,
        size = UI.Text.Size.XL,
        color = UI.Color.yellow,
        shadow = UI.Text.Shadow.Large,
    })
    table.insert(menu.Elements, titleText)

    table.insert(menu.Elements, UI.FlexBox:new({
        receiveInput = true,
        alignCentered = true,
        y = 100,
        gap = 3,
        direction = UI.FlexDirection.VERTICAL,
        elements = {
            UI.Button:new({
                color = UI.ButtonColorVariant.GREEN,
                --focused = true,
                text = {
                    {
                        content = 'PLAY',
                        alignY = UI.Align.Y.MIDDLE,
                        alignX = UI.Align.X.CENTER,
                        shadow = UI.Text.Shadow.Small,
                    },
                },
                action = function()
                    PushEvent('scenechange', 'LOADING')
                end
            }),
            UI.Button:new({
                color = UI.ButtonColorVariant.YELLOW,
                text = {
                    {
                        content = 'SETTINGS',
                        alignY = UI.Align.Y.MIDDLE,
                        alignX = UI.Align.X.CENTER,
                        shadow = UI.Text.Shadow.Small,
                    },
                },
                action = function()
                    print('SETTINGS PRESSED')
                end
            }),
            UI.Button:new({
                color = UI.ButtonColorVariant.RED,
                text = {
                    {
                        content = 'QUIT',
                        alignY = UI.Align.Y.MIDDLE,
                        alignX = UI.Align.X.CENTER,
                        shadow = UI.Text.Shadow.Small,
                    },
                },
                action = function()
                    PushEvent('quit')
                end
            })
        }
    }))
    return menu
end

function Menu:keypressed()
    if Input.ESC() then
        PushEvent('quit')
        return
    end
    local i = Input.State({ignore = {'ESC'}})
    -- Print_r(i)
    for _, elem in pairs(self.Elements) do
        elem:propagateInput(i, 'key')
    end
end

return Menu