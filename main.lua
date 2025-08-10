require("util.globals")
require("event")
local StateMachine = require("state")
local UI = require("ui.prelude")
local Input = require("input")
local tts = require("util.tts")
local State

love.handlers = love.handlers

function love.load()
	math.randomseed(os.time())
	GlobalsLoad()
	UI.load()
	State = StateMachine:new()
	tts.load()
end

function love.handlers.scenechange(scene, arg1, arg2)
	State:handleSceneChange(scene, arg1, arg2)
end

function love.update(dt)
	tts.update()
	State:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
	Input.Poll(scancode, true)
	State:keypressed()
end

function love.keyreleased(key, scancode)
	Input.Poll(scancode, false)
	State:keypressed()
end

function love.draw()
	love.graphics.setCanvas(BackBuffer)
	love.graphics.clear(UI.Color.lightblue)
	State:draw()
	love.graphics.setCanvas()
	love.graphics.draw(BackBuffer)

	if false then
		local w, h = love.graphics.getDimensions()
		local lineDraw = function(div)
			local wstep, hstep = w * (1 / div), h * (1 / div)
			local lw, lh
			repeat
				lw = w - (wstep * (div - 1))
				lh = h - (hstep * (div - 1))
				love.graphics.line(0, lh, w, lh)
				love.graphics.line(lw, 0, lw, h)
				div = div - 1
			until div <= 1
		end
		local div = 8
		PushColor()
		love.graphics.setColor(1, 0, 0)
		lineDraw(div)
		PopColor()
	end
end
