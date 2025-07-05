local Globals = require('util.globals')
local main_menu = require('states.main_menu')
local loading = require('states.loading')
local lobby = require('states.lobby')
local countdown = require('states.countdown')
local error = require('states.error')
local gameplay_loop = require('states.gameplay_loop')

-- I NEED TO DECIDE IF I WANT TO CALL THESE SCENES OR STATES............... HELP ME LOL

---@enum StateEnum
local stateEnum = {
    SPLASH = 1,
    MAIN_MENU = 2,
    LOBBY = 3,
    LOADING = 4,
    COUNTDOWN = 5,
    ERROR = 6,
    GAMEPLAY_LOOP = 7,
}
local state_private = {
    {},
    main_menu,
    lobby,
    loading,
    countdown,
    error,
    gameplay_loop,
}

local state = {}
state.currentState = stateEnum.MAIN_MENU
state.StateEnum = stateEnum

function state.load()
    for _, scene in ipairs(state_private) do
        if scene.load then
            scene.load()
        end
    end
end

function state.handleSceneChange(scene, arg1, arg2)
    local lastState = state.currentState

    if Globals.Debug then
        local lastStateStr = 'UNDEFINED'
        for k, v in pairs(stateEnum) do
            if v == lastState then
                lastStateStr = k
                break
            end
        end
        print('\nScene transition:\nLeaving: ' .. lastStateStr .. '\nEntering: ' .. scene .. '\n')
    end

    state.currentState = stateEnum[scene]
    if state_private[state.currentState].onEnter then
        state_private[state.currentState].onEnter(arg1, arg2)
    end
    if state_private[lastState].onLeave then
        state_private[lastState].onLeave(arg1)
    end
end

function state.update(dt)
    if state_private[state.currentState].update then
        state_private[state.currentState].update(dt)
    end
end

function state.keypressed()
    if state_private[state.currentState].keypressed then
        state_private[state.currentState].keypressed()
    end
end

function state.keyreleased(scancode)
    if state_private[state.currentState].keyreleased then
        state_private[state.currentState].keyreleased()
    end
end

function state.draw()
    state_private[state.currentState].draw()
end

return state