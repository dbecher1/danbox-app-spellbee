local ffi = require('util.tts.engine.espeak')
-- Using this module to hopefully allow for easier swapping out of a better TTS model in the future

local Engine = {}

function Engine.init()
    ffi.init()
end

function Engine.speak(data)
    ffi.speak(data)
end

return Engine