local main_menu = require('states.main_menu')
local loading = require('states.loading')
local lobby = require('states.lobby')

---@enum StateEnum
local stateEnum = {
    SPLASH = 1,
    MAIN_MENU = 2,
    LOBBY = 3,
    LOADING = 4,
}
local state_private = {
    {},
    main_menu,
    lobby,
    loading,
}

local state = {}
state.currentState = stateEnum.MAIN_MENU
state.StateEnum = stateEnum

function state.load()
    loading.load()
    lobby.load()
    main_menu.load()
end

function state.handleSceneChange(scene, arg)
    local lastState = state.currentState
    state.currentState = stateEnum[scene]
    if state_private[state.currentState].onEnter then
        state_private[state.currentState].onEnter(arg)
    end
    if state_private[lastState].onLeave then
        state_private[lastState].onLeave()
    end
end

function state.update(dt)
    if state_private[state.currentState].update then
        state_private[state.currentState].update(dt)
    end
end

function state.keypressed(key, scancode, isrepeat)
    if state_private[state.currentState].keypressed then
        state_private[state.currentState].keypressed()
    end
end

function state.keyreleased(key, scancode, isrepeat)
    if state_private[state.currentState].keypressed then
        state_private[state.currentState].keypressed()
    end
end

function state.draw()
    state_private[state.currentState].draw()
end

return state