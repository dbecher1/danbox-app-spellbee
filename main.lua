require('util.mod')
require('event')
local State = require('state')
local UI = require('ui.prelude')
local Input = require('input')
local Globals = require('util.globals')
local tts = require('util.tts')

function love.load()
    math.randomseed(os.time())
    UI.load()
    State.load()
    Globals.load()
    tts.load()
end

function love.handlers.scenechange(scene, arg1, arg2)
    State.handleSceneChange(scene, arg1, arg2)
end

function love.update(dt)
    tts.update()
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
    love.graphics.clear(UI.Color.lightblue)

    State.draw()

    love.graphics.setCanvas()
    love.graphics.draw(Globals.BackBuffer)
end