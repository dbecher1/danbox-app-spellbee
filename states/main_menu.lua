local menu_private = {
    Elements = {},
    Text = {},
}
local menu = {}

local UI = require('ui.prelude')
local Globals = require('util.globals')
local Input = require('input')

function menu.load()
    menu_private.debugText = UI.Text:new{
        content = 'MENU'
    }
    table.insert(menu_private.Elements, UI.Text:new({
        content = 'BepisBee',
        alignX = UI.Align.X.CENTER,
        y = 50,
        size = UI.Text.Size.XL,
        color = {1, 1, 0.2},
        shadowSize = 3.0,
    }))
    table.insert(menu_private.Elements, UI.FlexBox:new({
        receiveInput = true,
        alignY = UI.Align.Y.MIDDLE,
        alignX = UI.Align.X.CENTER,
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
                        shadowSize = 1.0,
                    },
                },
                action = function()
                    print('PLAY PRESSED')
                    love.event.push('scenechange', 'LOADING')
                end
            }),
            UI.Button:new({
                color = UI.ButtonColorVariant.YELLOW,
                text = {
                    {
                        content = 'SETTINGS',
                        alignY = UI.Align.Y.MIDDLE,
                        alignX = UI.Align.X.CENTER,
                        shadowSize = 1.0,
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
                        shadowSize = 1.0,
                    },
                },
                action = function()
                    print('QUIT PRESSED')
                end
            })
        }
    }))
end

function menu.onEnter()
    print('main menu: onStart')
end

function menu.onLeave()
    print('main menu: onLeave')
end

function menu.keypressed()
    if Globals.Debug then
        -- Util.print_r(Input)
    end
    for _, elem in pairs(menu_private.Elements) do
        if elem.receiveInput then
            elem:propagateInput(Input, 'key')
        end
    end
end

function menu.update(dt)

end

function menu.draw()
    if Globals.Debug then
        menu_private.debugText:draw()
    end
    for _, ui in pairs(menu_private.Elements) do
        ui:draw()
    end
end

return menu