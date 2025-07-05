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
local grade_intro = require('states.game.grade_intro')
local guess_round = require('states.game.guess_round')

local GameplayStates = {
    TUTORIAL = 1,
    GRADE_INTRO = 2,
    GUESS_ROUND = 3,
}

local private = {
    Elements = {},
}

private.gameplay_states = {
    {},
    grade_intro,
    guess_round,
}

local state = {}
state.currentState = -1

function state.load()
    for _, scene in ipairs(private.gameplay_states) do
        if scene.load then
            scene.load()
        end
    end
end

function state.onEnter(gamestate)
    -- in the future we can specify what grade we start
    -- let's start for now at 5th grade
    gamestate.starting_grade = 5
    gamestate.network_thread = Thread:rehydrate(gamestate.network_thread)
    private.gamestate = gamestate
    private.currentState = GameplayStates.GRADE_INTRO
    private.gameplay_states[private.currentState].onEnter(gamestate.starting_grade)
end

function state.onLeave()

end

function state.transition(to)

end

function state.keypressed()
    if private.gameplay_states[private.currentState].keypressed then
        private.gameplay_states[private.currentState].keypressed()
    end
end

function state.update(dt)
    if private.gameplay_states[private.currentState].update then
        private.gameplay_states[private.currentState].update(dt)
    end
    local e
    if private.gameplay_states[private.currentState].poll then
        e = private.gameplay_states[private.currentState].poll()
    end
    if e then
        if e == 'next' then
            print('NEXTU')
        end
    end
end

function state.draw()
    private.gameplay_states[private.currentState].draw()

    -- Keep this element draw in case we want anything commonly drawn across states
    for _, elem in pairs(private.Elements) do
        elem:draw()
    end
end

return state