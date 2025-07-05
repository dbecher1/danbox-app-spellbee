
local buffer = {}

---@alias InputStateValue 'UP'|'DOWN'|'LEFT'|'RIGHT'|'ACTION'|'ESC'

---@class InputState
---@field package UP boolean
---@field package DOWN boolean
---@field package LEFT boolean
---@field package RIGHT boolean
---@field package ACTION boolean
---@field package ESC boolean
local InputState = {
    UP = false,
    DOWN = false,
    LEFT = false,
    RIGHT = false,
    ACTION = false,
    ESC = false,
}

---@class Input
---@field private state InputState
---@field private buffer [love.Scancode, boolean][]
local Input = {
    state = InputState,
    buffer = {},
}

---Resets entire input state to its default
function Input.Reset()
    for k, _ in pairs(Input.state) do
        Input.state[k] = false
    end
end

---Returns true if any key is pressed
---@return boolean
function Input.AnyKeyPressed()
    for _, k in pairs(Input.state) do
        if k then
            return true
        end
    end
    return false
end

---@return boolean
function Input.UP()
    return Input.state.UP
end

function Input.DOWN()
    return Input.state.DOWN
end

function Input.LEFT()
    return Input.state.LEFT
end

function Input.RIGHT()
    return Input.state.RIGHT
end

function Input.ACTION()
    return Input.state.ACTION
end

function Input.ESC()
    return Input.state.ESC
end

-- 'consumes' the key
-- takes a table of one of the two forms:
-- {only: [string]}
-- {ignore: [string]}
-- This will only consider a subset of keys, or ignore certain keys
-- Ensures that unwanted keypresses are not consumed
-- Examples that function the same:
-- Input.State({ignore = {'ESC', 'ACTION'}})
-- Input.State({only = {'UP', 'DOWN', 'LEFT', 'RIGHT'}})
---@param arg {ignore: [InputStateValue]} | {only: [InputStateValue]}
---@return [InputStateValue]
function Input.State(arg)
    local state = {}
    for k, v in pairs(Input.state) do
        if arg then
            if arg.ignore then
                for _, key in ipairs(arg.ignore) do
                    if key == k then goto continue end
                end
            elseif arg.only then
                local present = false
                for _, key in ipairs(arg.only) do
                    if key == k then present = true end
                end
                if not present then goto continue end
            end
        end
        if v then
            table.insert(state, k)
            Input.state[k] = false
        end
        ::continue::
    end
    return state
end

---Called on input events, sets the input state
---@param scancode love.Scancode
---@param pressed boolean
function Input.Poll(scancode, pressed)
    if scancode == 'w' or scancode == 'up' then
        if Input.state.UP ~= pressed then
            Input.state.UP = pressed
        end
    elseif scancode == 's' or scancode == 'down' then
        if Input.state.DOWN ~= pressed then
            Input.state.DOWN = pressed
        end
    elseif scancode == 'a' or scancode == 'left' then
        if Input.state.LEFT ~= pressed then
            Input.state.LEFT = pressed
        end
    elseif scancode == 'd' or scancode == 'right' then
        if Input.state.RIGHT ~= pressed then
            Input.state.RIGHT = pressed
        end
    elseif scancode == 'e' or scancode == 'return' then
        if Input.state.ACTION ~= pressed then
            Input.state.ACTION = pressed
        end
    elseif scancode == 'q' or scancode == 'escape' then
        if Input.state.ESC ~= pressed then
            Input.state.ESC = pressed
        end
    end
end

---Adds an input to the buffer queue
---@param scancode love.Scancode
---@param pressed boolean
function Input.Buffer(scancode, pressed)
    table.insert(Input.buffer, {scancode, pressed})
end

---Clears the input buffer, enacting all stored inputs
function Input.ClearBuffer()
    while #buffer > 0 do
        Input.Poll(unpack(table.remove(buffer, 1)))
    end
end

return Input