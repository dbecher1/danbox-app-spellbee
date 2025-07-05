local UI = {}

local button = require('ui.button')
local text = require('ui.text')
local align = require('ui.align')
local flexBox = require('ui.flexbox')
local color = require('ui.color')

UI.Button = button
UI.Text = text
UI.Align = align
UI.FlexBox = flexBox
UI.Color = color

UI.ButtonColorVariant = button.colorVariant
UI.FlexDirection = flexBox.Direction

function UI.load()
    UI.Button.load()
    UI.Text.load()
end

return UI