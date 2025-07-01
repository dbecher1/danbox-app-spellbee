
local align = {}

---@enum AlignX
local AlignX = {
    LEFT = 1,
    CENTER = 2,
    RIGHT = 3,
}
align.X = AlignX

---@enum AlignY
local AlignY = {
    TOP = 1,
    MIDDLE = 2,
    BOTTOM = 3,
}
align.Y = AlignY

---Converts alignment to strings
---@param x AlignX
---@return string
function align.toString(x)
    local xs = 'left'
    if x == AlignX.CENTER then
        xs = 'center'
    elseif x == AlignX.RIGHT then
        xs = 'right'
    end
    return xs
end

return align