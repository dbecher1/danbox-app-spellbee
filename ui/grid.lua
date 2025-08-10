local Component = require('ui.component')
local Container = require('ui.container')
local Text = require('ui.text')
local FlexBox = require('ui.flexbox')
--local UI = require('ui.prelude')

---@class Grid: Component A wrapper for a 2D flexbox with container elements that contain text. May be expanded upon in the future, but it just supports that right now
---@field inner_state FlexBox
---@field rowHeight integer
---@field border integer
---@field widths integer[]
---@field text_items Text[][]
---@field text_color Color?
---@field fill_color Color?
local Grid = Inherit(Component)

---@param texts string[]
---@param widths integer[]
---@param height integer
---@param border integer
---@param textColor Color?
---@param fillColor Color?
---@return FlexBox
---@return Text[]
local function gen_row(texts, widths, height, border, textColor, fillColor)
    assert(#texts == #widths, 'Grid widths and cells must be of the same length!')
    local fill = false
    if fillColor then
        fill = true
    end
    local elems = {}
    -- keep references to the text elements in order to individually set them
    local text_elems = {}
    for i, elm in ipairs(texts) do
        local t = Text:new({
            content = elm,
            alignCentered = true,
            color = textColor,
        })
        table.insert(text_elems, t)
        table.insert(elems, Container:new({
            fill = fill,
            border = border,
            fill_color = fillColor,
            dimensions = {widths[i], height},
            elements = {
                t
            }
        }))
    end
    return FlexBox:new({
        alignCentered = true,
        gap = 0,
        elements = elems
    }), text_elems
end

---@param g table
---@param headers string[] Header names
---@param widths integer[] Row widths
---@param items string[][]?
---@return Grid
function Grid:new(g, headers, widths, items)
    g = Component.new(self, g, 'grid')

    g.border = g.border or 0
    g.widths = widths

    assert(#headers == #widths, 'Grid widths and cells must be of the same length!')
    local headerRow, _ = gen_row(headers, widths, g.rowHeight, g.border, g.text_color, g.fill_color)

    ---@type FlexBox
    g.inner_state = FlexBox:new({
        direction = FlexBox.Direction.VERTICAL,
        gap = 0,
        alignCentered = g.alignCentered,
        alignX = g.alignX,
        alignY = g.alignY,
        x = g.x,
        y = g.y,
        parent = g.parent,
        elements = {headerRow}
    })

    g.text_items = {}
    items = items or {}

    for _, item in ipairs(items) do
        local row, t = gen_row(item, widths, g.rowHeight, g.border, g.text_color, g.fill_color)
        g.inner_state:append(row)
        table.insert(g.text_items, t)
    end

    return g
end

function Grid:row_iter()
    local idx = 1
    return function()
        local row = self.text_items[idx]
        if not row then return end
        local row_ = {}
        for _, c in ipairs(row) do
            table.insert(row_, c:getContent())
        end
        local idx_ = idx
        idx = idx + 1
        return idx_, unpack(row_)
    end
end

---Destroys the contents of the grid, save for the headers
function Grid:clear_cells()
    local recalculate = false
    while #self.inner_state.elements > 1 do
        recalculate = true
        table.remove(self.inner_state.elements)
    end
    if recalculate then
        self.inner_state:calculateDimensions()
    end
end

---@param contents string[]?
function Grid:append_row(contents)
    if not contents then
        contents = {}
        -- fill it with blank strings
        for _, _ in ipairs(self.widths) do
            table.insert(contents, '')
        end
    end
    local row, t = gen_row(contents, self.widths, self.rowHeight, self.border, self.text_color, self.fill_color)
    self.inner_state:append(row)
    table.insert(self.text_items, t)
end

function Grid:set_cell(row, col, content)
    self.text_items[row][col]:setContent(content)
end

---@param idx integer The index of the row to set the contents of
---@param contents string[]
function Grid:set_row(idx, contents)
    for i, content in ipairs(contents) do
        self:set_cell(idx, i, content)
    end
end

function Grid:draw()
    self.inner_state:draw()
end

return Grid