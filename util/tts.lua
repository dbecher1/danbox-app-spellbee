--local ffi = require('util.tts.engine.espeak')
local tts_engine = require('util.tts.engine')
local tts = {}
local tts_ = {}
local Thread = require('network.thread')

function tts.load()
	tts_engine.init()
	tts_.thread = Thread:new({
		path = 'util/tts/tts_thread.lua',
		name = 'tts'
	})
	tts_.thread:new_channel('cb')
	tts_.thread:start()

	tts_.callback_queue = {}
	tts_.speaking = false
end

function tts.speak(data)
	tts_.thread:send(data)
end

function tts.speak_many(...)
	local arg = {...}
	for i, data in ipairs(arg) do
		tts.speak(data)
	end
end

function tts.after_speak_many(fn, ...)
	local arg = {...}
	for i, data in ipairs(arg) do
		if i == #arg then
			tts.speak_then(data, fn)
		else
			tts.speak(data)
		end
	end
end

-- Similar to the above, but enacts a callback function when the speaking is done
function tts.speak_then(data, fn)
	tts_.callback_queue[data] = fn
	tts_.thread:send_on('cb', data)
end

function tts.update()
	local speaking = tts_.thread:receive()
	if speaking ~= nil then
		tts_.speaking = speaking
	end
	local e = tts_.thread:receive_on('cb')
	if e then
		-- call the function and then remove the entry
		if tts_.callback_queue[e] then
			tts_.callback_queue[e]()
		end
		tts_.callback_queue[e] = nil
	end
end

function tts.is_speaking()
	return tts_.speaking
end

return tts