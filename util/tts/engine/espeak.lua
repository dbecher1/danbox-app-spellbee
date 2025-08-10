local ffi = require("ffi")
local system = require("love.system")
ffi.cdef([[
typedef enum {
	AUDIO_OUTPUT_PLAYBACK,
	AUDIO_OUTPUT_RETRIEVAL,
	AUDIO_OUTPUT_SYNCHRONOUS,
	AUDIO_OUTPUT_SYNCH_PLAYBACK

} espeak_AUDIO_OUTPUT;
typedef enum {
	EE_OK=0,
	EE_INTERNAL_ERROR=-1,
	EE_BUFFER_FULL=1,
	EE_NOT_FOUND=2
} espeak_ERROR;
typedef enum {
	POS_CHARACTER = 1,
	POS_WORD,
	POS_SENTENCE
} espeak_POSITION_TYPE;
int espeak_Initialize(espeak_AUDIO_OUTPUT output, int buflength, const char *path, int options);
espeak_ERROR espeak_SetVoiceByName(const char *name);
espeak_ERROR espeak_Synth(const void *text,
	size_t size,
	unsigned int position,
	espeak_POSITION_TYPE position_type,
	unsigned int end_position,
	unsigned int flags,
	unsigned int* unique_identifier,
	void* user_data);
]])

local output = ffi.new("espeak_AUDIO_OUTPUT", "AUDIO_OUTPUT_SYNCH_PLAYBACK")
local buflength = 1024
local ffi_ = {}

local lib_name
local os = system.getOS()
if os == "OS X" then
	lib_name = "assets/libespeak-ng.dylib"
elseif os == "Linux" then
	lib_name = "assets/libespeak-ng.so"
end
ffi_.espeak = ffi.load(lib_name)

function ffi_.init()
	local init = ffi_.espeak.espeak_Initialize(output, buflength, nil, 0)
	local flag2 = ffi_.espeak.espeak_SetVoiceByName("English")
end

function ffi_.speak(data)
	local flag = ffi_.espeak.espeak_Synth(data, buflength, 0, 0, 0, 0, nil, nil)
end

return ffi_

