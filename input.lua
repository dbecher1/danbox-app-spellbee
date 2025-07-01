local Util = require('util.mod')

local Input = {
    UP = false,
    DOWN = false,
    LEFT = false,
    RIGHT = false,
    ACTION = false,
    ESC = false,
}

function Input.Poll(scancode, pressed)
    if scancode == 'w' or scancode == 'up' then
        if Input.UP ~= pressed then
            Input.UP = pressed
        end
    elseif scancode == 's' or scancode == 'down' then
        if Input.DOWN ~= pressed then
            Input.DOWN = pressed
        end
    elseif scancode == 'a' or scancode == 'left' then
        if Input.LEFT ~= pressed then
            Input.LEFT = pressed
        end
    elseif scancode == 'd' or scancode == 'right' then
        if Input.RIGHT ~= pressed then
            Input.RIGHT = pressed
        end
    elseif scancode == 'e' or scancode == 'return' then
        if Input.ACTION ~= pressed then
            Input.ACTION = pressed
        end
    elseif scancode == 'q' or scancode == 'escape' then
        if Input.ESC ~= pressed then
            Input.ESC = pressed
        end
    end
end

return Input