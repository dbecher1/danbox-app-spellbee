local State = require('state')
local UI = require('ui.prelude')
local Input = require('input')
local Globals = require('util.globals')

function love.load()
    math.randomseed(os.time())
    UI.load()
    State.load()
    Globals.load()
end

function love.handlers.scenechange(scene, arg)
    State.handleSceneChange(scene, arg)
end

function love.update(dt)
    State.update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    Input.Poll(scancode, true)
    State.keypressed()
end

function love.keyreleased(key, scancode)
    Input.Poll(scancode, false)
    State.keypressed()
end

function love.draw()
    love.graphics.setCanvas(Globals.BackBuffer)
    love.graphics.clear(UI.Pallet.activePallet.clearColor)

    State.draw()

    love.graphics.setCanvas()
    love.graphics.draw(Globals.BackBuffer)
end