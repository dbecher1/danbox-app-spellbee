local UI = {}

local button = require('ui.button')
local pallet = require('ui.pallet')
local text = require('ui.text')
local align = require('ui.align')
local flexBox = require('ui.flexbox')

UI.Button = button
UI.Pallet = pallet
UI.Text = text
UI.Align = align
UI.FlexBox = flexBox

UI.ButtonColorVariant = button.colorVariant
UI.FlexDirection = flexBox.Direction

function UI.load()
    UI.Button.load()
    UI.Text.load()
end

return UI