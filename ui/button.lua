local Util = require('util.mod')
local Text = require('ui.text')
local Align = require('ui.align')

local button_private = {}
local Button = {}

-- probably a more elegant way to do this...
-- 

local colorsRef = {'Blue', 'Green', 'Red', 'Yellow'}

---@enum ColorVariant
local ColorVariant = {
    BLUE = 1,
    GREEN = 2,
    RED = 3,
    YELLOW = 4,
}
Button.colorVariant = ColorVariant

function Button.load()
    local path1, path2, path3 =
        'assets/sprites/ui/button/',
        '/button_rectangle_gradient.png',
        '/button_rectangle_flat.png'
    for _, c in pairs(colorsRef) do
        local path = path1 .. c .. path2
        local pressedPath = path1 .. c .. path3
        local k1 = 'button' .. c
        local k2 = 'button' .. c .. 'Pressed'
        button_private[k1] = love.graphics.newImage(path)
        button_private[k2] = love.graphics.newImage(pressedPath)
    end
    -- Util.print_r(button_private)
    button_private.arrow_yellow_right = love.graphics.newImage('assets/sprites/ui/arrow/Yellow/arrow_basic_e.png')
end

---@class ButtonArgs
---@field color ColorVariant?
---@field x number?
---@field y number?
---@field w number?
---@field h number?
---@field alignX AlignX?
---@field alignY AlignY?
---@field position {number: number, number: number}?
---@field size {number: number, number:number}?
---@field text [TextArgs]?

---@class Button
---@field color ColorVariant
---@field x number
---@field y number
---@field w number
---@field h number
---@field alignX AlignX
---@field alignY AlignY
---@field pressed boolean
---@field focused boolean
---@field textElements table
---@param b ButtonArgs
function Button:new(b)
    b = b or {}
    setmetatable(b, self)
    self.__index = self
    b.color = b.color or Button.colorVariant.BLUE
    if b.position then
        b.x = b.position[1]
        b.y = b.position[2]
        b.position = nil
    else
        b.x = b.x or 0
        b.y = b.y or 0
    end

    if b.size then
        b.w = b.size[1]
        b.h = b.size[2]
        b.size = nil
    else
        b.w = b.w or 200
        b.h = b.h or 150
    end

    b.pressed = false
    b.textElements = {}

    if b.text then
        for _, t in pairs(b.text) do
            table.insert(b.textElements, Text:new(t))
        end
        b.text = nil
    end

    b.focused = b.focused or false
    b.selected = b.selected or false
    b.action = b.action or nil

    b.alignX = b.alignX or Align.X.LEFT
    b.alignY = b.alignY or Align.Y.TOP
    b.id = b.id or ''
    b.active = b.active or true
    return b
end

function Button:find(id)
    if self.id == id then return self end
    for _, elem in pairs(self.textElements) do
        local try = elem.find(id)
        if try then return try end
    end
    return nil
end

---@param t Text
--- The position of text elements will be RELATIVE to the position of the button!!
function Button:addText(t)
    table.insert(self.textElements, t)
end

function Button:getDimensions()
    local sprite = 'button' .. colorsRef[self.color]
    return button_private[sprite]:getDimensions()
end

function Button:update()

end

function Button:draw(offset, parentDim)
    offset = offset or {0, 0}
    local sprite = 'button' .. colorsRef[self.color]
    if self.focused then
        sprite = sprite .. 'Pressed'
    end
    local pw, ph = button_private[sprite]:getDimensions()

    local boundsW, boundsH

    if parentDim then
        boundsW = parentDim[1]
        boundsH = parentDim[2]
    else
        boundsW, boundsH = State.screenSize()
    end

    local pos = {
        self.x + offset[1],
        self.y + offset[2]
    }

    if self.alignX == Align.X.CENTER then
        pos[1] = pos[1] + (0.5 * boundsW) - (0.5 * pw)
    elseif self.alignX == Align.X.RIGHT then
        pos[1] = pos[1] + boundsW - pw
    end

    if self.alignY == Align.Y.MIDDLE then
        pos[2] = pos[2] + (0.5 * boundsH) - (0.5 * ph)
    elseif self.alignY == Align.Y.BOTTOM then
        pos[2] = pos[2] + boundsH - ph
    end

    -- TODO: make use of the size field, don't just go off the sprite size
    love.graphics.draw(
        button_private[sprite],
        math.floor(pos[1]),
        math.floor(pos[2])
    )

    for _, t in pairs(self.textElements) do
        t:draw(
            pos,
            {pw, ph}
        )
    end

    if self.selected then
        local _, arrowH = button_private.arrow_yellow_right:getDimensions()
        love.graphics.draw(
            button_private.arrow_yellow_right,
            math.floor(pos[1] -  50),
            math.floor(pos[2] + (0.5 * ph) - (0.5 * arrowH))
        )
    end
end

return Button