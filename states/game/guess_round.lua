local UI = require('ui.prelude')
local tts = require('util.tts')
local GLSB = require('states.game.game_loop_state_base')

---@class GuessRound: GameLoopStateBase
---@field gamestate GameStateObject
---@field activePlayer integer
---@field currentPlayerLabel Text
---@field nextPlayerLabel Text
---@field yourLevelWordIs Text
---@field timer integer
---@field timerLabel Text
---@field guessText Text
---@field answerText Text
---@field upNextLabel Text
---@field guessingState boolean
---@field playerIndex string[] A simple array of player names
local state = Inherit(GLSB)

--- What will be fun when I polish things more is to have the TTS say some stuff at specified values. Also, to have it turn different colors depending on the value of the timer
local TIMER_VALUE_DEFAULT = 60
local timer_counter = 0

function state:new()
    local s = GLSB.new(self)

    s.guessing = false
    s.timer = TIMER_VALUE_DEFAULT

    s.currentPlayerLabel = UI.Text:new({
        color = UI.Color.yellow,
        shadow = true,
    })
    s.nextPlayerLabel = UI.Text:new({
        --content = 'Johnnybill',
        shadow = true,
        size = UI.Text.Size.Small
    })

    s.upNextLabel = UI.Text:new({
        content = 'Up next:',
        shadow = true,
        size = UI.Text.Size.Small,
    })

    s.yourLevelWordIs = UI.Text:new({
        alignX = UI.Align.X.CENTER,
        alignY = UI.Align.Y.TOP,
        y = 100,
        active = false,
        shadow = UI.Text.Shadow.Small,
    })

    s.timerLabel = UI.Text:new({
        content = TIMER_VALUE_DEFAULT,
        alignX = UI.Align.X.RIGHT,
        alignY = UI.Align.Y.BOTTOM,
        x = -10,
        y = -10,
        size = UI.Text.Size.Large,
        active = false,
        color = UI.Color.yellow,
        shadow = true
    })

    table.insert(s.Elements, s.yourLevelWordIs)
    table.insert(s.Elements, s.timerLabel)

    s.guessText = UI.Text:new({
        alignCentered = true,
        size = UI.Text.Size.Large,
        shadow = true,
    })
    s.answerText = UI.Text:new({
        alignCentered = true,
        size = UI.Text.Size.Large,
        shadow = true,
    })

    table.insert(s.Elements, UI.FlexBox:new({
        id = 'guess-answer-box',
        direction = UI.FlexDirection.VERTICAL,
        gap = 6,
        elements = {
            s.guessText,
            s.answerText,
        },
        alignCentered = true,
    }))

    table.insert(s.Elements, UI.FlexBox:new({
        id = 'player-info-fb',
        direction = UI.FlexDirection.VERTICAL,
        gap = 12,
        x = 5,
        y = 5,
        elements = {
            UI.FlexBox:new({
                direction = UI.FlexDirection.HORIZONTAL,
                gap = 10,
                elements = {
                    UI.Text:new({
                        content = 'Currently playing:',
                        shadow = true
                    }),
                    s.currentPlayerLabel,
                }
            }),
            UI.FlexBox:new({
                direction = UI.FlexDirection.HORIZONTAL,
                gap = 7,
                elements = {
                    s.upNextLabel,
                    s.nextPlayerLabel,
                }
            }),
        }
    }))
    return s
end

---@private
function state:startGuess()
    -- TODO: configure the network thread and server side of things
    self.timerLabel:activate()
    self.timer = TIMER_VALUE_DEFAULT
    self.guessing = true
    local payload = {
        event = 'turnstart',
        player = self.playerIndex[self.activePlayer],
    }
    self.gamestate.network_thread:send(payload)
end

---@private
function state:issueGreeting()
    local playerName = self.playerIndex[self.activePlayer]
    if self.playerIndex[self.activePlayer + 1] then
        self.nextPlayerLabel:setContent(self.playerIndex[self.activePlayer + 1])
    else
        self.nextPlayerLabel:deactivate()
        self.upNextLabel:deactivate()
    end
    local gradeStr = self.gen_grade_str(self.gamestate.current_grade)
    local gradeStrMsg = 'Your ' .. gradeStr .. ' level word is:'
    --Print_r(self.gamestate)
    local word = self.gamestate.words[tostring(self.gamestate.current_grade)][self.activePlayer]
    self.gamestate.current_word = word
    self.gamestate.current_player = playerName

    self.currentPlayerLabel:setContent(playerName)
    tts.speak_then(
        'Okay, ' .. playerName,
        function()
            self.yourLevelWordIs:activate()
            self.yourLevelWordIs:setContent(gradeStrMsg)
            tts.after_speak_many(
                function()
                    self:startGuess()
                end,
                gradeStrMsg, word, 'Your time starts now'
            )
        end
    )
end

function state:nextPlayer()
    self.yourLevelWordIs:deactivate()
    if self.activePlayer == #self.playerIndex then
        self:push_event('next')
        return
    end
    self.activePlayer = self.activePlayer + 1
    self.guessText:setContent('')
    self.answerText:setContent('')
    self:issueGreeting()
end

---@private
function state:initialize_defaults()
    self.activePlayer = 1
    timer_counter = 0
    self.guessing = false
    self.activePlayer = 1
    self.playerIndex = {}
    for k, _ in pairs(self.gamestate.players) do
        table.insert(self.playerIndex, k)
    end
    self.nextPlayerLabel:activate()
    self.upNextLabel:activate()
    -- set the text elements to inactive
    self.timerLabel:deactivate()
    self.timerLabel:setContent(TIMER_VALUE_DEFAULT)
    self.timer = TIMER_VALUE_DEFAULT
    self.guessText:setContent('')
    self.answerText:setContent('')
end

---@param gamestate GameStateObject
function state:onEnter(gamestate)
    self.gamestate = gamestate
    self:initialize_defaults()
    self:issueGreeting()
end

---@private
---@param guess string
---@return 'incorrect'|'partial'|'correct'
---@return number
function state:eval_guess(guess)
    local result, score
    if guess == self.gamestate.current_word then
        result, score = 'correct', (110 * self.gamestate.current_grade)
        self.answerText:setColor('green')
    else
        local scoreSum = 0

        for i = 1, math.min(#guess, #self.gamestate.current_word) do
            if guess:sub(i, i) == self.gamestate.current_word:sub(i, i) then
                scoreSum = scoreSum + 1
                --print('match', guess:sub(i, i), self.gamestate.current_word:sub(i, i))
            end
        end
        -- normalize to length
        scoreSum = (math.floor(((scoreSum / #self.gamestate.current_word) * 100) + 0.5)) * self.gamestate.current_grade
        
        if scoreSum == 0 then
            result = 'incorrect'
            self.answerText:setColor('red')
        else
            result = 'partial'
            self.answerText:setColor('yellow')
        end
        score = scoreSum
    end

    tts.speak_then_and({
        {'Okay, ' .. self.gamestate.current_player, nil},
        {'You guess this spelling:', function() self.guessText:setContent(guess) end},
        {'The correct spelling is:', function() self.answerText:setContent(self.gamestate.current_word) end}
    })
    local response
    if result == 'correct' then
        response = {'', 'Well done!', 'You have earned a total of ' .. tostring(score) .. ' points'}
    elseif result == 'incorrect' then
        response = {'', 'Not even close. I am very sorry.', 'You have earned no points.'}
    else
        response = {'', 'You were close!', 'You have earned a total of ' .. tostring(score) .. ' points'}
    end
    tts.after_speak_many(
        function() self:nextPlayer() end,
        unpack(response)
    )

    return result, score
end

function state:update(dt)
    if self.guessing then
        timer_counter = timer_counter + dt
        if timer_counter >= 1 then
            timer_counter = 0
            self.timer = self.timer - 1
            self.timerLabel:setContent(self.timer)
        end
    end
    local e = self.gamestate.network_thread:receive()
    if e then
        if type(e) == 'table' then
            if e.event == 'guess' then
                self.timerLabel:deactivate()
                self.guessing = false
                local guess = e.guess
                local result, score = self:eval_guess(guess)
                self.gamestate.players[self.gamestate.current_player].score = self.gamestate.players[self.gamestate.current_player].score + score
                local payload = {
                    event = 'guessresult',
                    result,
                    player = self.gamestate.current_player
                }
            end
        end
    end
end

return state