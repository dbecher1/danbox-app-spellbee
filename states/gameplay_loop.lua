-- Gameplay flow is as follows:
-- When first starting, ask if they want tutorial
-- Determine a random order under the hood
-- Main loop:
-- Shows the grade level
-- For each player, give them the "Your _th grade level word is: ___"
-- Initial version will just have players guess the word and give points for correct or not, partial points for right letters
-- Full version will have "powerups" that can be used.
-- 1. Show the amount of letters in the word, maybe with one random letter?
-- 2. Re-roll
-- 3. Chaos - give the word to somebody else that hasn't gone
-- For now players that are not going just wait, but in the future let them guess the word too for bonus points
-- Also let them vote if the player will get the word right or not
-- Show the score after the following:
-- After 8th, 10th, 11th, grade, and at end of game
-- At end of game, play again with same players or go back to lobby

-- So this will break down the gameplay loop into these discrete states
-- 1. Tutorial
-- 2. Intro to grade
-- 3. Player guess
-- 4. Repeat 3 until all players go
-- 5. If finishing grades specified above, go to 6, if not, go to 2 and advance grade
-- 6. Show score, if after 12 go to 7, if not go to 2 and advance grade
-- 7. Announce winner, if play again go to 2 from 5th? grade, else go to menu and make new lobby

-- Which will be represented by these scenes in game
-- Tutorial
-- Intro
-- Main loop
-- Show score
-- End of game

local Thread = require('network.thread')
local StateBase = require('states.state_base')
local grade_intro = require('states.game.grade_intro')
local guess_round = require('states.game.guess_round')

---@alias GameStateObject {
---starting_grade: integer,
---players: table<string, PlayerState>,
---network_thread: Thread,
---words: WordBank,
---current_grade: integer,
---current_word: string?,
---current_player: string?}

---@enum GameplayState
local GameplayState = {
    GRADE_INTRO = 1,
    GUESS_ROUND = 2,
}

---@class GameplayLoop
---@field gameplay_states GameLoopStateBase[]
---@field currentState GameplayState
---@field gamestate GameStateObject
local GameplayLoop = Inherit(StateBase)

function GameplayLoop:new()
    local gameplay = StateBase.new(self)
    local gameplay_states = {
        grade_intro,
        guess_round,
    }
    gameplay.gameplay_states = {}
    for i, state in ipairs(gameplay_states) do
        gameplay.gameplay_states[i] = state:new()
    end
    gameplay.currentState = GameplayState.GRADE_INTRO
    gameplay.gamestate = {}
    return gameplay
end

---comment
---@param gamestate GameStateObject
function GameplayLoop:onEnter(gamestate)
    -- in the future we can specify what grade we start
    -- let's start for now at 5th grade
    gamestate.starting_grade = 5
    gamestate.current_grade = gamestate.starting_grade
    gamestate.network_thread = Thread:rehydrate(gamestate.network_thread)
    self.gamestate = gamestate

    -- TODO: eventually populate the players field with real players...
    if false then
        self.gamestate.players = {
        johnny = {
            connected = true,
            score = 0,
        },
        bill = {
            connected = true,
            score = 0
        },
        briantreumente = {
            connected = true,
            score = 0
        }
    }
    end

    self.currentState = GameplayState.GRADE_INTRO
    self.gameplay_states[self.currentState]:onEnter(gamestate.starting_grade)
end

function GameplayLoop:keypressed()
    self.gameplay_states[self.currentState]:keypressed()
end

function GameplayLoop:update(dt)
    self.gameplay_states[self.currentState]:update(dt)
    local e = self.gameplay_states[self.currentState]:poll_event()
    if e then
        if e == 'next' then
            local last_state = self.currentState
            if self.currentState == GameplayState.GRADE_INTRO then
                self.currentState = GameplayState.GUESS_ROUND
                self.gameplay_states[self.currentState]:onEnter(self.gamestate)
            end
            self.gameplay_states[last_state]:onLeave()
        end
    end
end

function GameplayLoop:draw()
    self.gameplay_states[self.currentState]:draw()
    -- Keep this element draw in case we want anything commonly drawn across states
    StateBase.draw(self)
end

return GameplayLoop