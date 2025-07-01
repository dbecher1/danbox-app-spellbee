
-- essentially an extension of the flexbox component to allow for columns/rows
-- I may eventually bake in handling for what happens if the limit is exceeded... but uh, please don't do that


local FlexBox = require("ui.flexbox")
local Align = require('ui.align')
local Text = require('ui.text')

---@enum MultiFlexFillBehavior
local MultiFlexFillBehavior = {
    FILL_FIRST = 1, -- if its hor
    FILL_EVEN = 2,
}

local MultiFlex = {}

function MultiFlex:new(mf)
    mf = mf or {}
    setmetatable(mf, self)
    self.__index = self
    mf.direction = mf.direction or FlexBox.Direction.HORIZONTAL
    mf.gap = mf.gap or 3
    mf.behavior = mf.behavior or MultiFlexFillBehavior.FILL_FIRST
    mf.num_boxes = mf.num_boxes or 2
    
end