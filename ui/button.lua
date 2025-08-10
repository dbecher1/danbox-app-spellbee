local Text = require('ui.text')
local Align = require('ui.align')
local Component = require('ui.component')

local button_private = {}
--local Button = setmetatable({}, {__index = Component})

---@class Button: Component
---@field color ColorVariant
---@field pressed boolean
---@field focused boolean
---@field selected boolean
---@field textElements Text[]
---@field action function?
local Button = Inherit(Component)

-- probably a more elegant way to do this...

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

function Button:new(b)
    b = Component.new(self, b, 'button')

    b.color = b.color or Button.colorVariant.BLUE

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

    return b
end

function Button:find(id)
    if self.id == id then return self end
    for _, elem in pairs(self.textElements) do
---@diagnostic disable-next-line: undefined-field
        if elem.find then
---@diagnostic disable-next-line: undefined-field
            local try = elem:find(id)
            if try then return try end
        end
    end
    return nil
end

--- The position of text elements will be RELATIVE to the position of the button!!
function Button:addText(t)
    table.insert(self.textElements, t)
end

function Button:getDimensions()
    local sprite = 'button' .. colorsRef[self.color]
    return button_private[sprite]:getDimensions()
end

function Button:component_type()
    return 'button'
end

function Button:draw(offset, parentDim)
    if not self.active then return end
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
        --boundsW, boundsH = State.screenSize()
        assert(false, 'FIX ME')
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
---@diagnostic disable-next-line: undefined-field
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