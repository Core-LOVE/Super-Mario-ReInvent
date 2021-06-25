local playerManager = {}

playerManager.eventListeners = {[true] = {},[false] = {}}
playerManager.registeredEvents = {[true] = {},[false] = {}}

local function tryCalledEvent(plr,isEarly,eventName,...)
    local objs = playerManager.eventListeners[isEarly][eventName]
    if objs == nil then
        return
    end

    objs = objs[plr.character]
    if objs == nil then
        return
    end
    
    for _,obj in ipairs(objs) do
        local library = obj[1]
        local functionName = obj[2] or eventName

        local func = library[functionName]

        if func ~= nil then
            func(plr,...)
        end
    end
end

function playerManager.registerEvent(id, library, eventName, functionName, isEarly)
    if isEarly == nil then
        isEarly = true
    end

    if playerManager.eventListeners[isEarly][eventName] == nil then
        local normalEventName = eventName:match("^(.+)Player$")


        playerManager.eventListeners[isEarly][eventName] = {}

        playerManager.registeredEvents[isEarly][eventName] = (function(...)
            -- Call events
            for _,p in ipairs(Player) do
                tryCalledEvent(p,isEarly,eventName,...)
            end
        end)

        registerEvent(playerManager.registeredEvents[isEarly],normalEventName,eventName,isEarly)
    end


    playerManager.eventListeners[isEarly][eventName]     = playerManager.eventListeners[isEarly][eventName]     or {}
    playerManager.eventListeners[isEarly][eventName][id] = playerManager.eventListeners[isEarly][eventName][id] or {}

    table.insert(playerManager.eventListeners[isEarly][eventName][id], {library,functionName})
end

return playerManager