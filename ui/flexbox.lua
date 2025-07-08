local Component = require('ui.component')
local Align = require('ui.align')
local Text = require('ui.text')
local Util = require('util.mod')

---@class FlexBox: Component
---@field gap number
---@field elements Component[]
---@field direction FlexDirection
---@field dimensions [number, number]
---@field selectedElement number
---@field receiveInput boolean
local FlexBox = Inherit(Component)

---@enum FlexDirection
local Direction = {
    HORIZONTAL = 1,
    VERTICAL = 2,
}

FlexBox.Direction = Direction

--The elements contained within must satisfy the following: have a getDimensions method, have a draw method with arguments offset and parentDim
function FlexBox:new(fb)
    fb = Component.new(self, fb, 'flexbox')

    fb.gap = fb.gap or 1
    fb.elements = fb.elements or {}

    fb.direction = fb.direction or Direction.HORIZONTAL
    fb.dimensions = {0, 0}

    if #fb.elements > 0 then
        fb.selectedElement = 1
        fb.elements[1].selected = true
    else
        fb.selectedElement = -1
    end
    fb.receiveInput = fb.receiveInput or false
    fb.calculateDimensions(fb)
    return fb
end

-- Given a tag/id, tries to find that element and returns it and its index, or nil if it can't
-- Requires an id field! 
function FlexBox:find(id)
    if self.id == id then return self end
    for i, elem in ipairs(self.elements) do
---@diagnostic disable-next-line: undefined-field
        local try = elem.find(id)
        if try then return try, i end
    end
    return nil
end

local function propagateInput(self, input, inputType)
    if self.selectedElement < 0 then return end
    if input == 'ACTION' then
        -- do something with the button and return
        -- maybe reset input state? too?
        if self.elements[self.selectedElement].action then
            self.elements[self.selectedElement].action()
        end
        return
    end
    local len = #self.elements
    local lastSelected = self.selectedElement
    if inputType == 'key' then
        if self.direction == Direction.HORIZONTAL then
            if input == 'RIGHT' then
                self.selectedElement = self.selectedElement + 1
                if self.selectedElement > len then
                    self.selectedElement = 1
                end
            elseif input == 'LEFT' then
                self.selectedElement = self.selectedElement - 1
                if self.selectedElement == 0 then
                    self.selectedElement = len
                end
            end
        elseif self.direction == Direction.VERTICAL then
            if input == 'DOWN' then
                self.selectedElement = self.selectedElement + 1
                if self.selectedElement > len then
                    self.selectedElement = 1
                end
            elseif input == 'UP' then
                self.selectedElement = self.selectedElement - 1
                if self.selectedElement == 0 then
                    self.selectedElement = len
                end
            end
        end
    end
    self.elements[lastSelected].selected = false
    self.elements[self.selectedElement].selected = true
end

---@overload fun(self: FlexBox, input_: [InputStateValue], inputType: 'key')
function FlexBox:propagateInput(input_, inputType)
    for _, input in ipairs(input_) do
        propagateInput(self, input, inputType)
    end
end

-- Caches size; helpful for handling mouse events and alignment modes
function FlexBox:calculateDimensions()
    local mainAxis, crossAxis = (-1 * self.gap), 0
    -- handle empty flexbox
    if #self.elements == 0 then
        self.dimensions = {0, 0}
        return
    end
    for _, elem in pairs(self.elements) do
        mainAxis = mainAxis + self.gap
        local w, h = elem:getDimensions()
        if self.direction == Direction.HORIZONTAL then
            mainAxis = mainAxis + w
            if h > crossAxis then
                crossAxis = h
            end
        elseif self.direction == Direction.VERTICAL then
            mainAxis = mainAxis + h
            if w > crossAxis then
                crossAxis = w
            end
        end
    end
    if self.direction == Direction.HORIZONTAL then
        self.dimensions[1] = mainAxis
        self.dimensions[2] = crossAxis
    elseif self.direction == Direction.VERTICAL then
        self.dimensions[1] = crossAxis
        self.dimensions[2] = mainAxis
    end
end

function FlexBox:append(element)
    table.insert(self.elements, element)
    self:calculateDimensions()
end

-- Given a string, creates a text element to add to this flexbox. Helper method.
function FlexBox:append_text(element, id)
    id = id or element
    local t = Text:new({
        content = element,
        id = id,
        shadowSize = 1,
    })
    self:append(t)
end

-- Given an id value of an element, tries to find it and remove it
-- Silently fails if it can't find that element ID
function FlexBox:remove(id)
    local e, i = self:find(id)
    if e then
        table.remove(self.elements, i)
        self:calculateDimensions()
    end
end

function FlexBox:clear()
    self.elements = {}
end

-- Offset will probably never be used, but this will let flexboxes be nested
function FlexBox:draw(offset, parentDim)
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
    if self.alignX == Align.X.CENTER then
        drawPos[1] = drawPos[1] + (0.5 * boundsW) - (0.5 * self.dimensions[1])
    elseif self.alignX == Align.X.RIGHT then
        drawPos[1] = drawPos[1] + boundsW - self.dimensions[1]
    end

    if self.alignY == Align.Y.MIDDLE then
        drawPos[2] = drawPos[2] + (0.5 * boundsH) - (0.5 * self.dimensions[2])
    elseif self.alignY == Align.Y.BOTTOM then
        drawPos[2] = drawPos[2] + boundsH - self.dimensions[2]
    end
    for _, elem in pairs(self.elements) do
---@diagnostic disable-next-line: undefined-field
        elem:draw(drawPos, self.dimensions)
        local ew, eh = elem:getDimensions()
        if self.direction == Direction.HORIZONTAL then
            drawPos[1] = drawPos[1] + ew + self.gap
        elseif self.direction == Direction.VERTICAL then
            drawPos[2] = drawPos[2] + eh + self.gap
        end
    end
end

return FlexBox