Uuid = require("util.uuid").uuid
Print_r = require("util.print_r").print_r
Input = require("input")

Debug = true
WEB_HOST = "127.0.0.1"
WEB_PORT = 4000
WEB_PATH = "/socket/websocket?vsn=2.0.0"

function GlobalsLoad()
	BackBuffer = love.graphics.newCanvas()
	GameID = Uuid()
end

local colorStack = {}

---Saving the previous color only to restore it later is a common enough operation that it's wrapped in PushColor and PopColor global functions
PushColor = function()
	local r, g, b, a = love.graphics.getColor()
	table.insert(colorStack, { r, g, b, a })
end

---Saving the previous color only to restore it later is a common enough operation that it's wrapped in PushColor and PopColor global functions
---If the color stack is empty and this is called in error, it will just do nothing
PopColor = function()
	if #colorStack == 0 then
		return
	end
	local color = table.remove(colorStack, #colorStack)
	local r, g, b, a = unpack(color)
	love.graphics.setColor(r, g, b, a)
end

Inherit = function(parent)
	return setmetatable({}, { __index = parent })
end

Table = {}

---@alias Array table<integer, any>

---Given a table, returns an array of its keys
---@param t table
---@return table
Table.keyset = function(t)
	local ks = {}
	for k, _ in pairs(t) do
		table.insert(ks, k)
	end
	return ks
end

---Returns true if an array contains a given value
---@param t Array
---@param e any
---@return boolean
Table.array_contains = function(t, e)
	for _, v in ipairs(t) do
		if v == e then
			return true
		end
	end
	return false
end
