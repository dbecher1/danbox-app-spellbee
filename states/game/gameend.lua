local GLSB = require('states.game.game_loop_state_base')
local tts = require('util.tts')
local UI = require('ui.prelude')

---@class GameEnd: GameLoopStateBase
---@field playerText Text
local GameEnd = Inherit(GLSB)

function GameEnd:new()
    local s = GLSB.new(self)

    s.playerText = UI.Text:new({
        shadow = true,
        alignCentered = true,
        color = UI.Color.yellow,
    })

    table.insert(s.Elements, UI.FlexBox:new({
        direction = UI.FlexDirection.VERTICAL,
        gap = 10,
        alignX = UI.Align.X.CENTER,
        y = 10,
        elements = {
            UI.Text:new({
                size = UI.Text.Size.Large,
                shadow = true,
                alignCentered = true,
                color = UI.Color.yellow,
                content = 'Congratulations'
            }),
            s.playerText,
        }
    }))

    return s
end

---@param gamestate GameStateObject
function GameEnd:onEnter(gamestate)
    self.playerText:setContent(gamestate.winner)
    tts.speak_many(
        'Congratulations,' .. gamestate.winner .. '!',
        'You have done it. I am so proud.',
        'If you would like to play again,',
        'Please dont because I have not coded that yet. Thank you!'
    )
end

function GameEnd:onLeave()

end

return GameEnd