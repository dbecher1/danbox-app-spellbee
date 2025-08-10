local main_menu = require('states.main_menu')
local loading = require('states.loading')
local lobby = require('states.lobby')
local countdown = require('states.countdown')
local error = require('states.error')
local gameplay_loop = require('states.gameplay_loop')
local StateBase = require('states.state_base')
local test_env = require('states.test_env')

---@enum GameState
local GameState = {
    MAIN_MENU = 1,
    LOBBY = 2,
    LOADING = 3,
    COUNTDOWN = 4,
    ERROR = 5,
    GAMEPLAY_LOOP = 6,
    TEST_ENV = 7,
}
local states_ = {
    main_menu,
    lobby,
    loading,
    countdown,
    error,
    gameplay_loop,
    test_env,
}

---@class StateMachine
---@field gameStates StateBase[]
---@field currentState GameState
local StateMachine = {}

function StateMachine:new()
    local state = StateBase.new(self)
    state.gameStates = {}
    for i, s in ipairs(states_) do
        state.gameStates[i] = s:new()
    end
    self.currentState = GameState.MAIN_MENU
    --self.currentState = GameState.TEST_ENV
    return state
end

function StateMachine:handleSceneChange(scene, arg1, arg2)
    local lastState = self.currentState

    if Debug then
        local lastStateStr = 'UNDEFINED'
        for k, v in pairs(GameState) do
            if v == lastState then
                lastStateStr = k
                break
            end
        end
        print('\nScene transition:\nLeaving: ' .. lastStateStr .. '\nEntering: ' .. scene .. '\n')
    end

    self.currentState = GameState[scene]

    self.gameStates[self.currentState]:onEnter(arg1, arg2)
    self.gameStates[lastState]:onLeave(arg1)
end

function StateMachine:update(dt)
    self.gameStates[self.currentState]:update(dt)
end

function StateMachine:keypressed()
    self.gameStates[self.currentState]:keypressed()
end

function StateMachine:keyreleased(scancode)
    self.gameStates[self.currentState]:keyreleased()
end

function StateMachine:draw()
    self.gameStates[self.currentState]:draw()
end

return StateMachine