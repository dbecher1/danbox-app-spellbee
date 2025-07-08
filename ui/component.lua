-- Base UI component to be inherited from

local Align = require('ui.align')

---@class Component
---@field id string
---@field x number
---@field y number
---@field dimensions [number, number]
---@field alignX AlignX
---@field alignY AlignY
---@field active boolean
local Component = {}

local component_ids = {}

---Generates an ID for a component
---@param name string
---@return string
local function generate_id(name)
    if component_ids[name] then
        local id = name .. '-' .. component_ids[name]
        component_ids[name] = component_ids[name] + 1
        return id
    else
        component_ids[name] = 0
        return generate_id(name)
    end
end

function Component:new(c, name)
    c = c or {}
    name = name or 'component'
    setmetatable(c, self)
    self.__index = self

    if c.position then
        c.x = c.position[1]
        c.y = c.position[2]
        c.position = nil
    else
        c.x = c.x or 0
        c.y = c.y or 0
    end

    c.dimensions = c.dimensions or {0, 0}

    if c.alignCentered ~= nil and c.alignCentered then
        c.alignX = Align.X.CENTER
        c.alignY = Align.Y.MIDDLE
    else
        c.alignX = c.alignX or Align.X.LEFT
    c.alignY = c.alignY or Align.Y.TOP
    end

    c.id = c.id or generate_id(name)

    if c.active == nil then
        c.active = true
    end

    return c
end

function Component:getDimensions()
    return self.dimensions[1], self.dimensions[2]
end

function Component:activate()
    self.active = true
end

function Component:deactivate()
    self.active = false
end

function Component:set_active(active)
    self.active = active
    print(self.id)
end

function Component:receiveInput()
    return false
end

function Component:propagateInput(input, type) end

return Component