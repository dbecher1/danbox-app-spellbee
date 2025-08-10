local Component = require('ui.component')
local Color = require('ui.color')
local Align = require('ui.align')

-- this needs a lot of looking at, it's really sloppy atm
-- I might want to make it a container for just -one- element

---@class Container: Component
---@field elements Component[]
---@field fill boolean
---@field border integer
---@field border_color Color
---@field fill_color Color
---@field margin [number, number]
---@field rounding number
---@field clip boolean
---@field paddingX integer
---@field paddingY integer
local Container = Inherit(Component)

function Container:new(c)
    c = Component.new(self, c, 'container')
    c.border = c.border or 0
    c.border_color = c.border_color or Color.black
    ---@type Component[]
    c.elements = c.elements or {}
    c.rounding = c.rounding or 0
    if c.clip == nil then
        c.clip = false
    end
    if c.fill == nil then
        c.fill = false
    end
    c.fill_color = c.fill_color or Color.white
    c.margin = c.margin or {c.marginX or 0, c.marginY or 0}
    if c.dimensions[1] == 0 and c.dimensions[2] == 0 then
        for _, elem in ipairs(c.elements) do
            local w, h = elem:getDimensions()
            c.dimensions[1] = math.max(c.dimensions[1], w)
            c.dimensions[2] = math.max(c.dimensions[2], h)
        end
    end
    c.paddingX = c.padding or c.paddingX or 0
    c.paddingY = c.padding or c.paddingY or 0
    return c
end

function Container:component_type()
    return 'container'
end

function Container:draw(offset, parentDim)
    if not self.active then return end
    offset = offset or {0, 0}
    local boundsW, boundsH
    if parentDim then
        boundsW = parentDim[1]
        boundsH = parentDim[2]
    else
        boundsW, boundsH = love.graphics.getDimensions()
    end
    local drawPos = {
        self.x + offset[1],
        self.y + offset[2]
    }
    local drawDim = {
        self.dimensions[1] + (self.paddingX * 2),
        self.dimensions[2] + (self.paddingY * 2)
    }
    if self.alignX == Align.X.CENTER then
        --drawPos[1] = drawPos[1] + (0.5 * boundsW) - (0.5 * self.dimensions[1])
        drawPos[1] = drawPos[1] + (0.5 * boundsW) - (0.5 * drawDim[1])
    elseif self.alignX == Align.X.RIGHT then
        --drawPos[1] = drawPos[1] + boundsW - self.dimensions[1]
        drawPos[1] = drawPos[1] + boundsW - drawDim[1]
    end

    if self.alignY == Align.Y.MIDDLE then
        --drawPos[2] = drawPos[2] + (0.5 * boundsH) - (0.5 * self.dimensions[2])
        drawPos[2] = drawPos[2] + (0.5 * boundsH) - (0.5 * drawDim[2])
    elseif self.alignY == Align.Y.BOTTOM then
        --drawPos[2] = drawPos[2] + boundsH - self.dimensions[2]
        drawPos[2] = drawPos[2] + boundsH - drawDim[2]
    end

    --drawPos = {drawPos[1] - self.paddingX,drawPos[2] - self.paddingY}

    PushColor()
    if self.fill then
        love.graphics.setColor(unpack(self.fill_color))
        love.graphics.rectangle('fill', drawPos[1], drawPos[2], self.dimensions[1], self.dimensions[2], self.rounding, self.rounding)
        --love.graphics.rectangle('fill', drawPos[1], drawPos[2], drawDim[1], drawDim[2], self.rounding, self.rounding)
    end
    if self.clip then
        --love.graphics.setScissor(drawPos[1], drawPos[2], self.dimensions[1], self.dimensions[2])
    end
    for _, elem in ipairs(self.elements) do
        --elem:draw(drawPos, self.dimensions)
        elem:draw(drawPos, drawDim)
    end
    if self.clip then
        love.graphics.setScissor()
    end
    if self.border > 0 then
        love.graphics.setColor(unpack(self.border_color))
        love.graphics.rectangle('line',
            drawPos[1] - self.border,
            drawPos[2] - self.border,
            self.dimensions[1] + (2 * self.border),
            self.dimensions[2] + (2 * self.border)
            --self.rounding + self.outline,
            --self.rounding + self.outline
        )
    end
    PopColor()
end

return Container