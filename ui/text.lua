---@diagnostic disable: undefined-doc-name
local Util = require('util.mod')
local Align = require('ui.align')

local text_private = {
    Font = {}
}
local Text = {}
local font_path = 'assets/fonts/Kenney Future.ttf'

---@enum TextSize
local TextSize = {
    Small = 1,
    Medium = 2,
    Large = 3,
    XL = 4,
}

Text.Size = TextSize

function Text.load()
    text_private.Font = {
        love.graphics.newFont(font_path, 12),
        love.graphics.newFont(font_path, 24),
        love.graphics.newFont(font_path, 48),
        love.graphics.newFont(font_path, 96),
    }
    love.graphics.setFont(text_private.Font[TextSize.Medium])
    --text_private.shader = love.graphics.newShader('assets/shaders/text_border.glsl')
    text_private.shadowShader = love.graphics.newShader('assets/shaders/text_shadow.glsl')
end

---@alias Color {number: number, number:number, number: number, number:number}

---@class TextArgs
---@field x number?
---@field y number?
---@field size TextSize?
---@field position {number: number, number: number}?
---@field color Color?
---@field content string?
---@field alignX AlignX?
---@field alignY AlignY?

---@class Text
---@field x number If centered, acts as an offset
---@field y number
---@field alignX AlignX
---@field alignY AlignY
---@field inner_state love.graphics.Text
---@field color Color
---@field draw function
---@param t TextArgs
---@return Text
function Text:new(t)
    t = t or {}
    setmetatable(t, self)
    self.__index = self
    if t.position then
        t.x = t.position[1]
        t.y = t.position[2]
        t.position = nil
    else
        t.x = t.x or 0
        t.y = t.y or 0
    end
    local size = t.size or TextSize.Medium
    t.size = nil
    local color = t.color or {1, 1, 1, 1}
    --t.color = nil
    local content = t.content or ''
    t.content = nil
    t.inner_state = love.graphics.newText(text_private.Font[size], content)
    t.alignX = t.alignX or Align.X.LEFT
    t.alignY = t.alignY or Align.Y.TOP
    local alignXStr = 'left'
    if t.alignX == Align.X.CENTER then
        alignXStr = 'center'
    elseif t.alignX == Align.X.RIGHT then
        alignXStr = 'right'
    end
    t.shadowSize = t.shadowSize or 0
    t.borderSize = t.borderSize or 0
    t.id = t.id or ''
    t.active = t.active or true
    --t.inner_state:setf({color, content}, 500, alignXStr)
    return t
end

function Text:find(id)
    if self.id == id then return self
    else return nil
    end
end

---@param content string
function Text:setContent(content)
    self.inner_state:set(content)
end

function Text:getDimensions()
    return self.inner_state:getDimensions()
end

---@param offset {number: number, number: number}? This will be the position of the parent UI element, if exists
---@param parentDim {number: number, number: number}? w, h
function Text:draw(offset, parentDim)
    if not self.active then return end
    offset = offset or {0, 0}
    local drawPos = {
        x = self.x + offset[1],
        y = self.y + offset[2],
    }
    love.graphics.setColor(self.color or {1, 1, 1})
    --love.graphics.setColor{1, 1, 1}
    local boundsW, boundsH
    -- TODO: shadow
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

    if self.shadowSize > 0 then
        love.graphics.setShader(text_private.shadowShader)
        text_private.shadowShader:send('shadowSize', self.shadowSize);
        love.graphics.draw(self.inner_state, math.floor(drawPos.x), math.floor(drawPos.y))
        love.graphics.setShader()
    end

    love.graphics.draw(self.inner_state, math.floor(drawPos.x), math.floor(drawPos.y))
end

return Text