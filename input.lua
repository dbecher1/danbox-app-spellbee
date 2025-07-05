local Util = require('util.mod')

local buffer = {}
local Input = {}
local input_ = {
    UP = false,
    DOWN = false,
    LEFT = false,
    RIGHT = false,
    ACTION = false,
    ESC = false,
}

function Input.Reset()
    for k, _ in pairs(input_) do
        input_[k] = false
    end
end

function Input.AnyKeyPressed()
    for _, k in pairs(input_) do
        if k then
            return true
        end
    end
    return false
end

function Input.UP()
    return input_.UP
end

function Input.DOWN()
    return input_.DOWN
end

function Input.LEFT()
    return input_.LEFT
end

function Input.RIGHT()
    return input_.RIGHT
end

function Input.ACTION()
    return input_.ACTION
end

function Input.ESC()
    return input_.ESC
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
function Input.State(arg)
    local state = {}
    for k, v in pairs(input_) do
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
            input_[k] = false
        end
        ::continue::
    end
    return state
end

function Input.Poll(scancode, pressed)
    if scancode == 'w' or scancode == 'up' then
        if input_.UP ~= pressed then
            input_.UP = pressed
        end
    elseif scancode == 's' or scancode == 'down' then
        if input_.DOWN ~= pressed then
            input_.DOWN = pressed
        end
    elseif scancode == 'a' or scancode == 'left' then
        if input_.LEFT ~= pressed then
            input_.LEFT = pressed
        end
    elseif scancode == 'd' or scancode == 'right' then
        if input_.RIGHT ~= pressed then
            input_.RIGHT = pressed
        end
    elseif scancode == 'e' or scancode == 'return' then
        if input_.ACTION ~= pressed then
            input_.ACTION = pressed
        end
    elseif scancode == 'q' or scancode == 'escape' then
        if input_.ESC ~= pressed then
            input_.ESC = pressed
        end
    end
end

function Input.Buffer(scancode, pressed)
    table.insert(buffer, {scancode, pressed})
end

function Input.ClearBuffer()
    while #buffer > 0 do
        Input.Poll(table.remove(buffer, 1))
    end
end

return Input