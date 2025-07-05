local Util = require('util.mod')
local Align = require('ui.align')
local Component = require('ui.component')
local Color = require('ui.color')

local text_private = {
    Font = {}
}

---@class Text: Component
---@field size TextSize
---@field inner_state love.Text
---@field shadow Shadow
---@field borderSize number
---@

local Text = Inherit(Component)
local font_path = 'assets/fonts/Kenney Future.ttf'

---@enum TextSize
local TextSize = {
    Small = 1,
    Medium = 2,
    Large = 3,
    XL = 4,
}

---@enum Shadow
local Shadow = {
    None = 0,
    Small = 1,
    Medium = 2,
    Large = 3,
    XL = 4,
}

Text.Size = TextSize
Text.Shadow = Shadow

function Text.load()
    text_private.Font = {
        love.graphics.newFont(font_path, 16),
        love.graphics.newFont(font_path, 24),
        love.graphics.newFont(font_path, 48),
        love.graphics.newFont(font_path, 96),
    }
    love.graphics.setFont(text_private.Font[TextSize.Medium])
    --text_private.shader = love.graphics.newShader('assets/shaders/text_border.glsl')
    text_private.shadowShader = love.graphics.newShader('assets/shaders/text_shadow.glsl')
end

function Text:new(t)
    t = Component.new(self, t, 'text')

    local size = t.size or TextSize.Medium
    t.size = nil

    if t.color then
        if type(t.color) == 'string' and Color[t.color] then
            t.color = Color[t.color]
        end
    else
        t.color = Color.white
    end

    local content = t.content or ''
    t.content = nil

    t.inner_state = love.graphics.newText(text_private.Font[size], content)

    t.shadow = t.shadow or Shadow.None
    t.borderSize = t.borderSize or 0

    return t
end

function Text:find(id)
    if self.id == id then return self
    else return nil
    end
end

---@param content string
function Text:setContent(content)
    if type(content) ~= 'string' then
        content = tostring(content)
    end
    self.inner_state:set(content)
end

---@diagnostic disable-next-line: duplicate-set-field
function Text:getDimensions()
    return self.inner_state:getDimensions()
end

---@param offset [number, number]? This will be the position of the parent UI element, if exists
---@param parentDim [number, number]? w, h
function Text:draw(offset, parentDim)
    if not self.active then return end
    offset = offset or {0, 0}
    local drawPos = {
        x = self.x + offset[1],
        y = self.y + offset[2],
    }
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(self.color or {1, 1, 1})
    --love.graphics.setColor{1, 1, 1}
    local boundsW, boundsH

    if parentDim then
        boundsW = parentDim[1]
        boundsH = parentDim[2]
    else
        boundsW, boundsH = love.graphics.getDimensions()
    end

    -- take care of alignment
    -- x axis
    local selfSizeW, selfSizeH = self.inner_state:getDimensions()

    if self.alignX == Align.X.CENTER then
        -- TODO check this
        drawPos.x = drawPos.x + (0.5 * boundsW) - (0.5 * selfSizeW)
    elseif self.alignX == Align.X.RIGHT then
        drawPos.x = drawPos.x + boundsW - selfSizeW
    end

    -- y axis
    if self.alignY == Align.Y.MIDDLE then
        drawPos.y = drawPos.y + (0.5 * boundsH) - (0.5 * selfSizeH)
    elseif self.alignY == Align.Y.BOTTOM then
        drawPos.y = drawPos.y + boundsH - selfSizeH
    end

    if self.shadow > 0 then
        love.graphics.setShader(text_private.shadowShader)
        text_private.shadowShader:send('shadowSize', self.shadow);
        love.graphics.draw(self.inner_state, math.floor(drawPos.x), math.floor(drawPos.y))
        love.graphics.setShader()
    end

    love.graphics.draw(self.inner_state, math.floor(drawPos.x), math.floor(drawPos.y))

    love.graphics.setColor(r, g, b, a)
end

return Text