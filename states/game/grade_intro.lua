local UI = require('ui.prelude')
local tts = require('util.tts')

local private = {
    Elements = {},
    -- Gameplay states have their own event system so that it doesn't get intercepted by the Love events
    Event = {},
}
local state = {}

function state.load()
    private.grade_label = UI.Text:new({
        y = 20,
        color = UI.Color.yellow,
        shadow = UI.Text.Shadow.Large,
        size = UI.Text.Size.Large,
        alignCentered = true,
    })
    table.insert(private.Elements, UI.FlexBox:new({
        direction = UI.FlexDirection.VERTICAL,
        alignCentered = true,
        gap = 10,
        y = -100,
        elements = {
            UI.Text:new({
                content = 'Congratulations!',
                shadow = UI.Text.Shadow.Large,
                size = UI.Text.Size.Large,
                color = UI.Color.yellow,
                alignCentered = true,
            }),
            UI.Text:new({
                content = 'You are now entering:',
                shadow = UI.Text.Shadow.Small,
                size = UI.Text.Size.Medium,
                alignCentered = true,
            }),
            private.grade_label,
        }
    }))
end

local function gen_grade_str(grade)
    return tostring(grade) .. 'th grade'
end

---@param grade integer
function state.onEnter(grade)
    local gradeStr = gen_grade_str(grade)
    private.grade_label:setContent(gradeStr)
    tts.after_speak_many(
        function() table.insert(private.Event, 'next') end,
        'Congratulations!', 'You are now entering', gradeStr
    )
end

function state.onLeave()

end

function state.keypressed()

end

function state.update(dt)

end

function state.poll()
    if #private.Event == 0 then return nil end
    return table.remove(private.Event, 1)
end

function state.draw()
    for _, elem in pairs(private.Elements) do
        elem:draw()
    end
end

return state