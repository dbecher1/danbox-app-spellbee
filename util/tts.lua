local tts_engine = require('util.tts.engine')
local Thread = require('network.thread')

---@class TTS The interface that controls the underlying text-to-speech engine
---@field private thread Thread
---@field private speaking boolean
---@field private callback_queue table<string, function>
local tts = {}

local message = 0

function tts.load()
	tts_engine.init()
	tts.thread = Thread:new({
		path = 'util/tts/tts_thread.lua',
		name = 'tts'
	})
	tts.thread:new_channel('cb')
	tts.thread:start()

	tts.callback_queue = {}
	tts.speaking = false
end

---Sends text to the engine to speak
---@param data any
function tts.speak(data)
	tts.thread:send({
		data = data,
		n = message
	})
	message = message + 1
end

---Sends text to the engine to speak, calling a callback function on completion of the speech
---@param data string
---@param fn function
function tts.speak_then(data, fn)
	tts.callback_queue[data] = fn
	tts.thread:send({data = data, n = message}, 'cb')
	message = message + 1
end

---Naming things is very hard. This function takes an array of string function tuples, and executes them in turn. The function can be nil for flexibility (if you want a non-callback executed in between two callbacks)
---@param entries [string, function?][]
function tts.speak_then_and(entries)
	for _, entry in ipairs(entries) do
		local data, fn = unpack(entry)
		if fn then
			tts.speak_then(data, fn)
		else
			tts.speak(data)
		end
	end
end

---Sends an arbitrary amount of phrases to the engine. The engine is configured to have short pauses in between each phrase, so this is ideal for sentences.
---@param ... string
function tts.speak_many(...)
	local arg = {...}
	for _, data in ipairs(arg) do
		tts.speak(data)
	end
end

---Sends an arbitrary amount of phrases to the engine, calling a callback function after the final phrase
---@param fn function
---@param ... string
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

function tts.update()
	local speaking = tts.thread:receive()
	if speaking ~= nil then
		tts.speaking = speaking
	end
	local e = tts.thread:receive('cb')
	if e then
		-- call the function and then remove the entry
		if tts.callback_queue[e] then
			tts.callback_queue[e]()
		end
		tts.callback_queue[e] = nil
	end
end

---Returns true if the engine is currently speaking
---@return boolean
function tts.is_speaking()
	return tts.speaking
end

return tts