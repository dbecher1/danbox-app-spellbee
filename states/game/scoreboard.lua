local GLSB = require('states.game.game_loop_state_base')
local tts = require('util.tts')
local UI = require('ui.prelude')

---@class Scoreboard: GameLoopStateBase
---@field scoreboard Grid
local Scoreboard = Inherit(GLSB)

---@alias PlayerScores {name: string, score: number}[]

---@param p PlayerScores
---@param gameEnd boolean
function Scoreboard:say_score(p, gameEnd)
    if gameEnd then
        tts.after_speak_many(
            function()
                self:push_event('end')
            end,
            'Let us look at the final score',
            '',
            'What a wonderful game.',
            'Let us announce the winner'
        )
    else
        tts.after_speak_many(
            function()
                self:push_event('next')
            end,
            'Let us look at the score',
            '',
            'Wow! You can all spell so well',
            'I am very proud, especially of you, ' .. p[1].name,
            'Let us move on'
        )
    end
end

function Scoreboard:new()
    local s = GLSB.new(self)

    s.scoreboard = UI.Grid:new({
        y = -100,
        border = 1,
        alignCentered = true,
        text_color = UI.Color.black,
        fill_color = UI.Color.yellow,
        rowHeight = 50
    }, {'Player', 'Score'},
        {200, 120}
    )

    table.insert(s.Elements, s.scoreboard)

    table.insert(s.Elements, UI.Text:new({
        size = UI.Text.Size.Large,
        color = UI.Color.yellow,
        shadow = true,
        alignX = UI.Align.X.CENTER,
        y = 30,
        content = 'SCORE'
    }))

    return s
end

---@param players string[] A list of player names to populate the scoreboard with
function Scoreboard:loadPlayers(players)
    for _, player in ipairs(players) do
        self.scoreboard:append_row({player, '0'})
    end
end

---@param gamestate GameStateObject
function Scoreboard:onEnter(gamestate)
    -- update the scoreboard
    -- this can be animated in the future
    ---@type PlayerScores
    local p = {}
    for k, v in pairs(gamestate.players) do
        table.insert(p, {
            name = k,
            score = v.score
        })
    end
    table.sort(p, function(a, b) return a.score > b.score end)
    for i, player in ipairs(p) do
        self.scoreboard:set_row(i, {player.name, tostring(player.score)})
    end
    local gameEnd = false
    if gamestate.current_grade == 12 then
        gameEnd = true
        gamestate.winner = p[1].name
    end
    self:say_score(p, gameEnd)
end

function Scoreboard:onLeave()
    self.scoreboard:clear_cells()
end

return Scoreboard