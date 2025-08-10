local UI = require('ui.prelude')
local tts = require('util.tts')
local GLSB = require('states.game.game_loop_state_base')

---@class GradeIntro: GameLoopStateBase
---@field grade_label Text
local Intro = Inherit(GLSB)

function Intro:new()
    local intro = GLSB.new(self)
    intro.grade_label = UI.Text:new({
        y = 20,
        color = UI.Color.yellow,
        shadow = UI.Text.Shadow.Large,
        size = UI.Text.Size.Large,
        alignCentered = true,
    })
    table.insert(intro.Elements, UI.FlexBox:new({
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
            intro.grade_label,
        }
    }))
    return intro
end

---@param state GameStateObject
function Intro:onEnter(state)
    local gradeStr = self.gen_grade_str(state.current_grade)
    self.grade_label:setContent(gradeStr)
    tts.after_speak_many(
        function()
            self:push_event('next')
            state.network_thread:send({
                event = 'roundstart',
                grade = state.current_grade
            })
        end,
        'Congratulations!', 'You are now entering', gradeStr
    )
end

return Intro